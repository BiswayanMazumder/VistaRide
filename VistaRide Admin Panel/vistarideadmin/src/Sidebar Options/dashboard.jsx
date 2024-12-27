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
export default function Dashboard() {
    const [selectedIndex, setSelectedIndex] = useState(0);
    const [currentLocation, setCurrentLocation] = useState(null);
    const [mapContainerStyle, setMapContainerStyle] = useState({
        width: '100%',
        height: '100%',
    });
    const [drivers, setDrivers] = useState([]); // Store driver data
    const [unavaliabledrivers, setunavaliableDrivers] = useState([]); // Store driver data
    const [ridedoingdrivers, setridedoingDrivers] = useState([]);
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
                // console.log('Drivers Avaliable', driverList)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (driver) => driver['Driver Online'] == false || driver['Driver Avaliable'] == false
                    ); // Only drivers that are online and available

                setunavaliableDrivers(driverList); // Update the state with driver data
                // console.log('Drivers Unavaliable',driverList)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
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
                // console.log('Drivers Ride Doing', driverList)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [riders, setriders] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide User Details'),
            (snapshot) => {
                const riderlist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['User Name'] != null
                    ); // Only drivers that are online and available

                setriders(riderlist); // Update the state with driver data
                // console.log('Riders', riderlist)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [totalrides, settotalrides] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Booking ID'] != null
                    ); // Only drivers that are online and available

                settotalrides(rideslist); // Update the state with driver data
                // console.log('Rides', rideslist)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [completedrides, setcompletedrides] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Ride Completed']
                    ); // Only drivers that are online and available

                setcompletedrides(rideslist); // Update the state with driver data
                // console.log('Rides', rideslist)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [cancelledrides, setcancelledrides] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Ride Cancelled']
                    ); // Only drivers that are online and available

                    setcancelledrides(rideslist); // Update the state with driver data
                // console.log('Rides', rideslist)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };
    // Get the current location
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

    // Handle option click to update the selected index
    const handleOptionClick = (index) => {
        setSelectedIndex(index);
    };
    const mapCenter = currentLocation;
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="fnjnfjn">
                <div className="menfd">
                    Biswayan Mazumder
                </div>
                <div className="hehfhejfe">
                    Super Administrator
                </div>
            </div>
            <div className="jjnjnjnv">
                <div className="njdnvv">
                    <div className="jjvnjvnfv">
                        <div className="jndjvnjf">
                            God's View
                        </div>
                        <div className="jdjnjf">
                            <div className="jfhjhjvh" onClick={() => handleOptionClick(0)} style={{ boxShadow: selectedIndex == 0 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex == 0 ? 'black' : 'grey', border: selectedIndex == 0 ? '1px solid black' : null }}>
                                <img src='assets/images/driver_avaliable.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Avaliable
                                    <br /><br />
                                    <center>
                                        ({drivers.length})
                                    </center>

                                </div>
                            </div>
                            <div className="jfhjhjvh" onClick={() => handleOptionClick(1)} style={{ boxShadow: selectedIndex == 1 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex == 1 ? 'black' : 'grey', border: selectedIndex == 1 ? '1px solid black' : null }}>
                                <img src='assets/images/car_not_avaliable.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Not Avaliable
                                    <br /><br />
                                    <center>
                                        ({unavaliabledrivers.length})
                                    </center>
                                </div>
                            </div>
                            <div className="jfhjhjvh" onClick={() => handleOptionClick(2)} style={{ boxShadow: selectedIndex == 2 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex == 2 ? 'black' : 'grey', border: selectedIndex == 2 ? '1px solid black' : null }}>
                                <img src='assets/images/waytopickup.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Ride Doing
                                    <br /><br />
                                    <center>
                                        ({ridedoingdrivers.length})
                                    </center>
                                </div>
                            </div>
                            {/* <div className="jfhjhjvh" onClick={() => handleOptionClick(3)} style={{ boxShadow: selectedIndex == 3 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null,color:selectedIndex == 3 ?'black':'grey',border:selectedIndex == 3 ?'1px solid black':null }}>
                                <img src='assets/images/waytopickup.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Way to Dropoff
                                    <br /><br />
                                    <center>
                                        (0)
                                    </center>
                                </div>
                            </div> */}
                        </div>
                        <div className="jjnfjnfjvn">
                            <LoadScript
                                googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM"
                                libraries={['places']}
                            >
                                <GoogleMap
                                    mapContainerStyle={mapContainerStyle}
                                    center={mapCenter}
                                    zoom={12}
                                    options={mapOptions}
                                >
                                    {/* You can add markers or other map features if you want */}
                                    {selectedIndex == 0 ? (drivers.map((driver, index) => (
                                        <Marker
                                            key={index}
                                            icon={{
                                                url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea',  // Path to your custom icon
                                                scaledSize: new window.google.maps.Size(50, 50), // Adjust width and height here
                                            }}
                                            position={{
                                                lng: parseFloat(driver['Current Longitude']),
                                                lat: parseFloat(driver['Current Latitude']),
                                            }}
                                        />
                                    ))) : selectedIndex == 1 ? (unavaliabledrivers.map((driver, index) => (
                                        <Marker
                                            key={index}
                                            icon={{
                                                url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea',  // Path to your custom icon
                                                scaledSize: new window.google.maps.Size(50, 50), // Adjust width and height here
                                            }}
                                            position={{
                                                lng: parseFloat(driver['Current Longitude']),
                                                lat: parseFloat(driver['Current Latitude']),
                                            }}
                                        />
                                    ))) : (ridedoingdrivers.map((driver, index) => (
                                        <Marker
                                            key={index}
                                            icon={{
                                                url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea',  // Path to your custom icon
                                                scaledSize: new window.google.maps.Size(50, 50), // Adjust width and height here
                                            }}
                                            position={{
                                                lng: parseFloat(driver['Current Longitude']),
                                                lat: parseFloat(driver['Current Latitude']),
                                            }}
                                        />
                                    )))}
                                </GoogleMap>
                            </LoadScript>

                        </div>
                    </div>
                </div>
                <div className="njdnvv">
                    <div className="jnjnjvnf">
                        <div className="jdjvjf">
                            <img src='assets/images/activeusers.png' alt="" height={"50px"} width={"50px"} />
                            <div className="hdffbj" style={{ fontSize: '18px', fontWeight: '700' }}>
                                User
                            </div>
                            <div className="hdffbj">
                                {riders.length}
                            </div>
                        </div>
                        <div className="jdjvjf" onClick={() => handleOptionClick(0)}>
                            <div className="jdjvjf">
                                <img src='assets/images/driveravaliable.png' alt="" height={"50px"} width={"50px"} />
                                <div className="hdffbj" style={{ fontSize: '18px', fontWeight: '700', color: 'green' }}>
                                    Active<br />Driver
                                </div>
                                <div className="hdffbj" style={{ color: 'green' }}>
                                    {drivers.length}
                                </div>
                            </div>
                        </div>
                        <div className="jdjvjf" onClick={() => handleOptionClick(1)}>
                            <div className="jdjvjf">
                                <img src='assets/images/driveravaliable.png' alt="" height={"50px"} width={"50px"} />
                                <div className="hdffbj" style={{ fontSize: '18px', fontWeight: '700', color: 'orange' }}>
                                    Inactive<br />Driver
                                </div>
                                <div className="hdffbj" style={{ color: 'orange' }}>
                                    {unavaliabledrivers.length}
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="jjvnjvnfv" style={{ height: '500px', marginTop: '20px' }}>
                        <div className="jndjvnjf">
                            Trip Statistics
                        </div>
                        <div className="jhdjfhv">
                            <div className="ddhhdb">
                                <img src='assets/images/totalrides.png' alt="" height={"50px"} width={"50px"} />
                                <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '400' }}>
                                    Total Trips
                                </div>
                            </div>
                            <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '600', color: 'blue' }}>
                                {totalrides.length}
                            </div>
                        </div>
                        <div className="jhdjfhv">
                            <div className="ddhhdb">
                                <img src='assets/images/totalrides.png' alt="" height={"50px"} width={"50px"} />
                                <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '400' }}>
                                    Completed Trips
                                </div>
                            </div>
                            <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '600', color: 'green' }}>
                                {completedrides.length}
                            </div>
                        </div>
                        <div className="jhdjfhv">
                            <div className="ddhhdb">
                                <img src='assets/images/totalrides.png' alt="" height={"50px"} width={"50px"} />
                                <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '400' }}>
                                    Cancelled Trips
                                </div>
                            </div>
                            <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '600', color: 'red' }}>
                                {cancelledrides.length}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
