import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot } from 'firebase/firestore';

// Firebase config
const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:40aeb5d0434d67ca1ea368",
    measurementId: "G-9V0M9VQDGM"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

export default function Godview() {
    const [drivers, setDrivers] = useState([]); // Store driver data
    const [unavaliabledrivers, setunavaliableDrivers] = useState([]); // Store driver data
    const [ridedoingdrivers, setridedoingDrivers] = useState([]);
    const [mapLoaded, setMapLoaded] = useState(false);  // Track whether the map has loaded

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (driver) => driver['Driver Online'] && driver['Driver Avaliable']
                    ); // Only drivers that are online and available

                setDrivers(driverList); // Update the state with driver data
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        return () => unsubscribe();
    }, []);

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (driver) => driver['Driver Online'] === false || driver['Driver Avaliable'] === false
                    ); // Only drivers that are online and available

                setunavaliableDrivers(driverList); // Update the state with driver data
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        return () => unsubscribe();
    }, []);

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (driver) => driver['Driver Online'] && driver['Ride Doing'] != null
                    ); // Only drivers that are online and available

                setridedoingDrivers(driverList); // Update the state with driver data
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        return () => unsubscribe();
    }, []);

    const [selectedIndex, setSelectedIndex] = useState(0);
    const handleOptionClick = (index) => {
        setSelectedIndex(index);
    };

    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };

    const [mapContainerStyle, setMapContainerStyle] = useState({
        width: '100%',
        height: '100%',
    });

    const [currentLocation, setCurrentLocation] = useState(null);

    useEffect(() => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    setCurrentLocation({
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                    });
                },
                (error) => {
                    console.error(error);
                }
            );
        }
    }, []);

    const mapCenter = currentLocation;

    const handleMapLoad = () => {
        setMapLoaded(true); // Set map as loaded when the map is ready
    };

    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden', }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    God's View
                </div>
                <div className="divider"></div>
                <div className="jnjgnjg">
                    <div className="jfhjhjvh" onClick={() => handleOptionClick(0)} style={{ boxShadow: selectedIndex === 0 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex === 0 ? 'black' : 'grey', border: selectedIndex === 0 ? '1px solid black' : null }}>
                        <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/driver_avaliable.png' alt="" height={"80px"} width={"80px"} />
                        <div className="jdjvnj" >
                            Avaliable
                            <br /><br />
                            <center>
                                ({drivers.length})
                            </center>
                        </div>
                    </div>
                    <div className="jfhjhjvh" onClick={() => handleOptionClick(1)} style={{ boxShadow: selectedIndex === 1 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex === 1 ? 'black' : 'grey', border: selectedIndex === 1 ? '1px solid black' : null }}>
                        <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/car_not_avaliable.png' alt="" height={"80px"} width={"80px"} />
                        <div className="jdjvnj" >
                            Not Avaliable
                            <br /><br />
                            <center>
                                ({unavaliabledrivers.length})
                            </center>
                        </div>
                    </div>
                    <div className="jfhjhjvh" onClick={() => handleOptionClick(2)} style={{ boxShadow: selectedIndex === 2 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex === 2 ? 'black' : 'grey', border: selectedIndex === 2 ? '1px solid black' : null }}>
                        <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/waytopickup.png' alt="" height={"80px"} width={"80px"} />
                        <div className="jdjvnj" >
                            Ride Doing
                            <br /><br />
                            <center>
                                ({ridedoingdrivers.length})
                            </center>
                        </div>
                    </div>
                </div>
                <br /><br />
                <LoadScript
                    googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM"
                    libraries={['places']}
                >
                    <GoogleMap
                        mapContainerStyle={mapContainerStyle}
                        center={mapCenter}
                        zoom={12}
                        options={mapOptions}
                        onLoad={handleMapLoad}  // Set the map as loaded
                    >
                        {mapLoaded && selectedIndex === 0 ? (
                            drivers.map((driver, index) => (
                                <Marker
                                    key={index}
                                    icon={{
                                        url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea', 
                                        scaledSize: new window.google.maps.Size(50, 50),
                                    }}
                                    position={{
                                        lng: parseFloat(driver['Current Longitude']),
                                        lat: parseFloat(driver['Current Latitude']),
                                    }}
                                />
                            ))
                        ) : mapLoaded && selectedIndex === 1 ? (
                            unavaliabledrivers.map((driver, index) => (
                                <Marker
                                    key={index}
                                    icon={{
                                        url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea', 
                                        scaledSize: new window.google.maps.Size(50, 50),
                                    }}
                                    position={{
                                        lng: parseFloat(driver['Current Longitude']),
                                        lat: parseFloat(driver['Current Latitude']),
                                    }}
                                />
                            ))
                        ) : mapLoaded && selectedIndex === 2 ? (
                            ridedoingdrivers.map((driver, index) => (
                                <Marker
                                    key={index}
                                    icon={{
                                        url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea', 
                                        scaledSize: new window.google.maps.Size(50, 50),
                                    }}
                                    position={{
                                        lng: parseFloat(driver['Current Longitude']),
                                        lat: parseFloat(driver['Current Latitude']),
                                    }}
                                />
                            ))
                        ) : null}
                    </GoogleMap>
                </LoadScript>
            </div>
        </div>
    );
}
