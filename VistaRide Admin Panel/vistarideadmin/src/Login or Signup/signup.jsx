import React, { useEffect, useState } from 'react';
import { Link, useHistory } from 'react-router-dom';
import { initializeApp, getApps } from 'firebase/app';
import { getFirestore, doc, setDoc } from 'firebase/firestore';
import { getAuth, createUserWithEmailAndPassword, signOut } from 'firebase/auth';

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

// Initialize Firebase if not already initialized
let app;
if (!getApps().length) {
    app = initializeApp(firebaseConfig);
} else {
    app = getApps()[0];
}

const db = getFirestore(app);
const auth = getAuth(app);

export default function Signup() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [firstname, setFirstname] = useState('');
    const [lastname, setLastname] = useState('');
    // const history = useHistory();

    useEffect(() => {
        document.title = 'VistaRide Corporate';
    }, []);

    const handleEmailChange = (e) => {
        setEmail(e.target.value);
    };

    const handlePasswordChange = (e) => {
        setPassword(e.target.value);
    };

    const handleFirstnameChange = (e) => {
        setFirstname(e.target.value);
    };

    const handleLastnameChange = (e) => {
        setLastname(e.target.value);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        try {
            // Create user with Firebase Authentication
            const userCredential = await createUserWithEmailAndPassword(auth, email, password);
            const user = userCredential.user;

            // Save user info to Firestore
            await setDoc(doc(db, 'Admin Details', user.uid), {
                firstName: firstname,
                lastName: lastname,
                email: email,
                uid: user.uid,
                emailVerified: user.emailVerified,
                admin: false,
            });
            await signOut(auth);
           window.location.replace('/');
        } catch (error) {
            console.error("Error signing up:", error.message);
            alert('Error signing up: ' + error.message);
        }
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
                        <Link to={'/'} style={{ textDecoration: 'none', color: 'grey' }}>
                            <li className='dvcbvvdv'>LOG IN</li>
                        </Link>
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
                    <div className="nfvfb">
                        <div className="jjfjvnfnv">
                            Sign Up for your VistaRide account
                            <br />
                            <div className="jdbvbfv" style={{ marginTop: '20px' }}>
                                <input
                                    type="text"
                                    className='hdbvhbvhb'
                                    placeholder='Enter First Name'
                                    value={firstname}
                                    onChange={handleFirstnameChange}
                                />
                            </div>
                            <div className="jdbvbfv" style={{ marginTop: '20px' }}>
                                <input
                                    type="text"
                                    className='hdbvhbvhb'
                                    placeholder='Enter Last Name'
                                    value={lastname}
                                    onChange={handleLastnameChange}
                                />
                            </div>
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
                            <div className="hdvjfnb" onClick={handleSubmit}>
                                Sign Up
                            </div>
                        </div>
                        <div className="jdjn">
                            <div className='dnjnjnj'>
                                Existing User?
                            </div>
                            <Link style={{ textDecoration: 'none' }} to={'/'}>
                                <div className='mdnjvnjv'>
                                    Log In Now
                                </div>
                            </Link>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    );
}
