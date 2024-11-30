import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { GoogleMap, LoadScript, Marker, Polyline } from '@react-google-maps/api';
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth, GoogleAuthProvider, signInWithPopup } from "firebase/auth";

const provider = new GoogleAuthProvider();
const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:0f8c6be4228dba901ea368",
    measurementId: "G-ZFRR1BZQFV"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
// Get Auth instance and Google provider
const auth = getAuth(app);
const googleProvider = new GoogleAuthProvider();

export default function LandingPageMobile() {
    const [user, setUser] = useState(null);
    const [error, setError] = useState(null);

    const handleLogin = async () => {
        try {
            const result = await signInWithPopup(auth, googleProvider);
            const user = result.user;
            setUser(user);
        } catch (err) {
            setError(err.message);
        }
    };
    return (
        <div className='webbody' style={{backgroundColor: 'black'}}>
            <div className="jnnvfkvfk">
                <div className="hvfnvn">
                    <div className="mdnjvn">
                        VistaRide
                    </div>
                    <Link style={{ textDecoration: 'none', color: 'white' }} onClick={handleLogin}>
                        <div className="eefebfs" style={{ padding: "30px" }}>Log in</div>
                    </Link>
                </div>
                <div className="ndjvnjd">
                    <div className="ehfbehfb">
                        Go anywhere with VistaRide
                    </div>
                    <div className="ehfbehfbd">
                        Request a ride,hop in,and go.
                    </div>
                    <div className="njnv">
                        <input type="text" placeholder='Pickup Location' className='ehbfhebfe'/>
                    </div>
                    <div className="njnv" style={{ marginTop: "20px" }}>
                        <input type="text" placeholder='Drop Location' className='ehbfhebfe'/>
                    </div>
                </div>
            </div>
        </div>
    )
}
