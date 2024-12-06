import React, { useEffect, useState } from 'react';
import { onAuthStateChanged, getAuth } from "firebase/auth";
import { doc, getDoc, getFirestore } from "firebase/firestore";
import { initializeApp } from "firebase/app";
import { Link } from 'react-router-dom';
import { GoogleMap, LoadScript, Marker, Polyline } from '@react-google-maps/api';
const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:0f8c6be4228dba901ea368",
    measurementId: "G-ZFRR1BZQFV",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

export default function Tripdetailslaptop() {
    const [userName, setUserName] = useState(null);
    const [userPfp, setUserPfp] = useState(null);
    const [user, setUser] = useState('');
    const [error, setError] = useState(null);
    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
            if (currentUser) {
                setUser(currentUser.uid);
            } else {
                window.location.replace('/');
            }
        });

        return () => unsubscribe();
    }, []);
    const [drivername, setdrivername] = useState('');
    const [carimage, setcarimage] = useState('');
    const [carmodel, setcarmodel] = useState('');

    useEffect(() => {
        const fetchdrivers = async () => {
            const docref = doc(db, 'VistaRide Driver Details', localStorage.getItem('Driver ID'));
            const docSnap = await getDoc(docref);
            if (docSnap.exists()) {
                setdrivername(docSnap.data()['Name']);
                setcarimage(docSnap.data()['Car Photo']);
                setcarmodel(docSnap.data()['Car Name']);
            }
        }
        fetchdrivers();
    }, []);
    useEffect(() => {
        if (!user) return;

        const fetchUserDetails = async () => {
            try {
                const docRef = doc(db, "VistaRide User Details", user);
                const docSnap = await getDoc(docRef);

                if (docSnap.exists()) {
                    setUserName(docSnap.data()['User Name']);
                    setUserPfp(docSnap.data()['Profile Picture']);
                } else {
                    setError("No user data found.");
                }
            } catch (err) {
                setError(`Error fetching user data: ${err.message}`);
            }
        };

        fetchUserDetails();
    }, [user]);
    const [pickupLat, setPickupLat] = useState(null);
    const [pickupLng, setPickupLng] = useState(null);
    const [dropLat, setDropLat] = useState(null);
    const [dropLng, setDropLng] = useState(null);

    useEffect(() => {
        // Retrieve pickup and drop coordinates from localStorage
        const pickupLat = parseFloat(localStorage.getItem('Pickup Latitude'));
        const pickupLng = parseFloat(localStorage.getItem('Pickup Longitude'));
        const dropLat = parseFloat(localStorage.getItem('Drop Latitude'));
        const dropLng = parseFloat(localStorage.getItem('Drop Longitude'));

        // Set state if the coordinates are available
        if (pickupLat && pickupLng && dropLat && dropLng) {
            setPickupLat(pickupLat);
            setPickupLng(pickupLng);
            setDropLat(dropLat);
            setDropLng(dropLng);
        }
    }, []);
    const mapOptions = {
        zoomControl: false,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    }
    
    return (
        <div className='webbody'>
            <div className="ehfjfv" style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Link to={'/go/home'}>
                    <div className="hfejfw">
                        <svg width="100" height="30" xmlns="http://www.w3.org/2000/svg">
                            <rect width="100" height="30" fill="black" rx="5"></rect>
                            <text x="50%" y="50%" font-family="'Lobster', cursive" font-size="21" fill="white" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">
                                VistaRide
                            </text>
                        </svg>
                    </div>
                </Link>
                <div className="hfejfw" style={{ right: '100px', position: 'absolute', flexDirection: 'row', gap: '20px' }}>
                    <Link style={{ textDecoration: 'none', color: "white" }}>
                        <div className="dbvbvdhna" style={{ fontWeight: '600' }}>My Trips</div>
                    </Link>
                    <div className="dbvbvdhn">{userName}</div>
                    <div className="dbvbvdhn">
                        <img
                            src={userPfp}
                            alt=""
                            height="45px"
                            width="45px"
                            style={{ borderRadius: '50%' }}
                        />
                    </div>
                </div>
            </div>
            <div className="dnjfndndjn">
                <div className="rnrnv">
                    <Link style={{ textDecoration: 'none', color: "black" }} to={'/trips'}>
                        <div style={{ fontWeight: '600', fontSize: '18px', display: 'flex', flexDirection: 'row', gap: '10px' }}>
                            <div style={{ marginTop: '3.5px' }}><svg width="1em" height="1em" viewBox="0 0 24 24" fill="none"><title>Arrow left</title><path d="M22 13.5H6.3l5.5 7.5H8.3l-6.5-9 6.5-9h3.5l-5.5 7.5H22v3Z" fill="currentColor"></path></svg> </div>Back to trips
                        </div>
                    </Link>
                    <img src="https://d3i4yxtzktqr9n.cloudfront.net/riders-web-v2/853ebe0d95a62aca.svg" alt="" width={'100%'} style={{ borderRadius: '10px' }} />
                    <div className="djnvdnv">
                        Your trip
                    </div>
                    <div className="djnvdnv" style={{ fontWeight: '600', fontSize: '16px', display: 'flex', flexDirection: 'row', justifyContent: 'space-between', width: '100%', height: '30px', alignItems: 'center' }}>
                        <div>
                            {localStorage.getItem('Booking Time')} {localStorage.getItem('Ride Cancelled') == 'false' ?(`with ${drivername}`):<></>}
                        </div>
                        {localStorage.getItem('Ride Cancelled') === 'true' ? (<div style={{ color: 'white', background: 'red', padding: '5px', borderRadius: '5px', fontWeight: '600', fontSize: '15px' }}>
                            {'Cancelled'}
                        </div>) : <></>}

                    </div>
                    {localStorage.getItem('Ride Cancelled') == 'true' ? (<div style={{ marginTop: '30px', marginBottom: '40px', paddingBottom: '20px' }}>
                        <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM">
                            <GoogleMap
                                mapContainerStyle={{
                                    height: '300px',
                                    width: '100%',
                                }}
                                options={mapOptions}
                                center={{ lat: pickupLat, lng: pickupLng }}
                                zoom={17}
                            >
                                <Marker position={{ lat: pickupLat, lng: pickupLng, }} />
                            </GoogleMap>
                        </LoadScript>
                    </div>) :(<div style={{ marginTop: '30px', marginBottom: '40px', paddingBottom: '20px' }}>
                        <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM">
                            <GoogleMap
                                mapContainerStyle={{
                                    height: '300px',
                                    width: '100%',
                                }}
                                options={mapOptions}
                                center={{ lat: pickupLat, lng: pickupLng }}
                                zoom={17}
                            >
                                <Marker position={{ lat: pickupLat, lng: pickupLng, }} />
                            </GoogleMap>
                        </LoadScript>
                    </div>)}
                    {localStorage.getItem('Ride Cancelled') === 'true' ? <></> :
                        (<div>
                            <div className="djnvdnv" style={{ marginTop: '30px' }}>
                                Trip Details
                            </div>
                            <div className="djnvdnv" style={{ fontWeight: '600', fontSize: '16px', display: 'flex', flexDirection: 'row', width: '100%', height: '30px', alignItems: 'center', gap: "10px" }}>
                                <div style={{ marginTop: '5px' }}>
                                    <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none"><title>Road</title><path d="M23 23 17.5 1h-4v5h-3V1h-4L1 23h9.5v-5h3v5H23Zm-12.5-8V9h3v6h-3Z" fill="currentColor"></path></svg>
                                </div>
                                <div style={{ fontWeight: '500' }}>
                                    {localStorage.getItem('Distance')}
                                </div>
                            </div>
                            <div className="djnvdnv" style={{ fontWeight: '600', fontSize: '16px', display: 'flex', flexDirection: 'row', width: '100%', height: '30px', alignItems: 'center', gap: "10px" }}>
                                <div style={{ marginTop: '5px' }}>
                                    <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none"><title>Clock</title><path d="M12 1C5.9 1 1 5.9 1 12s4.9 11 11 11 11-4.9 11-11S18.1 1 12 1Zm6 13h-8V4h3v7h5v3Z" fill="currentColor"></path></svg>
                                </div>
                                <div style={{ fontWeight: '500' }}>
                                    {localStorage.getItem('Travel Time')}
                                </div>
                            </div>
                            <div className="djnvdnv" style={{ fontWeight: '600', fontSize: '16px', display: 'flex', flexDirection: 'row', width: '100%', height: '30px', alignItems: 'center', gap: "10px" }}>
                                <div style={{ marginTop: '5px' }}>
                                    <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none"><title>Tag</title><path d="m10 24 12-12V2H12L0 14l10 10Z" fill="currentColor"></path></svg>
                                </div>
                                <div style={{ fontWeight: '500' }}>
                                    ₹{localStorage.getItem('Fare')}
                                </div>
                            </div>
                            <div className="djnvdnv" style={{ fontWeight: '600', fontSize: '16px', display: 'flex', flexDirection: 'row', width: '100%', height: '30px', alignItems: 'center', gap: "10px" }}>
                                <div style={{ marginTop: '5px' }}>
                                    <svg width="1em" height="1em" viewBox="0 0 24 24" fill="none"><title>Credit card</title><path fill-rule="evenodd" clip-rule="evenodd" d="M1 4h22v4H1V4Zm0 7h22v9H1v-9Z" fill="currentColor"></path></svg>
                                </div>
                                <div style={{ fontWeight: '500' }}>
                                    Cash
                                </div>
                            </div>
                        </div>)
                    }
                    {localStorage.getItem('Ride Cancelled') === 'false' ?(<div>
                        <div className="djnvdnv" style={{ marginTop: '30px', fontWeight: '700' }}>
                        Route Details
                    </div>
                    <div className="djnvdnv" style={{ fontWeight: '600', fontSize: '16px', display: 'flex', flexDirection: 'row', width: '100%', height: '30px', alignItems: 'center', gap: "10px" }}>
                        <div style={{ marginTop: '5px' }}>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" color="#000000"><title>Circle</title><path d="M12 23c6.075 0 11-4.925 11-11S18.075 1 12 1 1 5.925 1 12s4.925 11 11 11Z" fill="currentColor"></path></svg>
                        </div>
                        <div style={{ fontWeight: '500' }}>
                            {localStorage.getItem('Pickup Location')}
                        </div>
                    </div>
                    <div className="djnvdnv" style={{ fontWeight: '600', fontSize: '16px', display: 'flex', flexDirection: 'row', width: '100%', height: '30px', alignItems: 'center', gap: "10px",marginTop:'50px',paddingBottom:'30px' }}>
                        <div style={{ marginTop: '5px' }}>
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" color="#000000"><title>Square</title><path d="M2 2h20v20H2V2Z" fill="currentColor"></path></svg>
                        </div>
                        <div style={{ fontWeight: '500' }}>
                            {localStorage.getItem('Drop Location')}
                        </div>
                    </div>
                    </div>):<></>}
                </div>
            </div>
        </div>
    )
}
