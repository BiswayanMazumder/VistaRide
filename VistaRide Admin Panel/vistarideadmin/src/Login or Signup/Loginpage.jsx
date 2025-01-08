import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { initializeApp, getApps } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

// Firebase config
const firebaseConfig = {
    apiKey: "AIzaSyBN_GrU-Ah7vdnRbtQlTmP8AiT3mi2jcik",
    authDomain: "ecalatee.firebaseapp.com",
    projectId: "ecalatee",
    storageBucket: "ecalatee.appspot.com",
    messagingSenderId: "27929103681",
    appId: "1:27929103681:web:8d32cf3493f26e9fe8e5c0",
    measurementId: "G-4RQYYSQ098"
};

// Initialize Firebase if not already initialized
let app;
if (!getApps().length) {
    app = initializeApp(firebaseConfig);
} else {
    app = getApps()[0];
}

const db = getFirestore(app);

export default function Loginpage() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    useEffect(() => {
        document.title = 'VistaRide Corporate';
    }, []);

    const handleEmailChange = (e) => {
        setEmail(e.target.value);
    };

    const handlePasswordChange = (e) => {
        setPassword(e.target.value);
    };

    const handleSubmit = () => {
        console.log('Email:', email);
        console.log('Password:', password);
        // Add your login logic here (e.g., Firebase authentication)
    };

    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'hidden', overflowX: 'hidden', backgroundColor: 'white' }}>
            <div className="hddhbfvhfv">
                <div style={{ height: '100%', width: 'fit-content', justifyContent: 'start', alignItems: 'center', display: 'flex', flexDirection: 'row' }}>
                    <img src="https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2FScreenshot_2024-11-22_204328-removebg-preview.png?alt=media&token=53712449-daaa-4f70-bb92-0ca64793111e" alt="" height={"80%"} />
                    <svg width="150" height="30" xmlns="http://www.w3.org/2000/svg">
                        <rect width="150" height="30" fill="white" rx="5"></rect>
                        <text x="50%" y="50%" font-family="'Lobster', cursive" font-size="15" fill="black" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">
                            VistaRide Corporate
                        </text>
                    </svg>
                </div>
                <div className="dvgfvv" style={{ height: '100%', width: 'fit-content', justifyContent: 'start', alignItems: 'center', display: 'flex', flexDirection: 'row', gap: '10px' }}>
                    <ul className='bhbdbdv'>
                        <li className='dvcbvvdv'>HOW IT WORKS</li>
                        <li className='dvcbvvdv'>RESOURCES</li>
                        <li className='dvcbvvdv'>CONTACT US</li>
                        <li className='dvcbvvdv'>DOCS</li>
                        <li className='dvcbvvdv'>HELP</li>
                    </ul>
                </div>
            </div>
            <div className="dvhvvj" style={{ position: 'relative' }}>
                <img
                    src="https://d2i2wbpdigru6u.cloudfront.net/bgv1.jpg"
                    alt=""
                    width="100%"
                    className="vfvdvdvb"
                />
                <div
                    className="ndbvbfvnv"
                    style={{
                        position: 'absolute',
                        top: '40%',
                        left: '50%',
                        transform: 'translate(-50%, -50%)',
                        color: 'white',
                        fontSize: '24px',
                        fontWeight: '500'
                    }}
                >
                    <div className="jrbjh">
                        <center>Now use VistaRide for Managing your Corporate Travel</center>
                        <br />
                        <div style={{ fontWeight: '500', fontSize: '15px' }}>
                            Its Easy, Safe and Efficient
                        </div>
                    </div>
                    <div className="jjfjvnfnv">
                        Log in to your VistaRide account
                        <br />
                        <div className="jdbvbfv" style={{ marginTop: '20px' }}>
                            <input
                                type="text"
                                className='hdbvhbvhb'
                                placeholder='Enter Email Address'
                                value={email}
                                onChange={handleEmailChange}
                            />
                        </div>
                        <div className="jdbvbfv">
                            <input
                                type="password"
                                className='hdbvhbvhb'
                                placeholder='Enter Password'
                                value={password}
                                onChange={handlePasswordChange}
                            />
                        </div>
                        <Link to={'/home'} style={{ textDecoration: 'none', color: 'white' }}>
                            <div className="hdvjfnb" onClick={() => {
                                handleSubmit();
                                window.location.replace('/home'); // Navigates without allowing back navigation
                            }}
                            >
                                Submit
                            </div>
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
