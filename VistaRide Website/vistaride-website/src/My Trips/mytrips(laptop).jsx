import React, { useEffect, useRef, useState } from 'react';
import { onAuthStateChanged, getAuth, signOut } from "firebase/auth";
import { arrayRemove, arrayUnion, collection, deleteField, doc, FieldValue, getDoc, getFirestore, onSnapshot, serverTimestamp, setDoc, updateDoc } from "firebase/firestore";
import { initializeApp } from "firebase/app";
import { GoogleMap, LoadScript, Marker, Polyline } from '@react-google-maps/api';
import { Link } from 'react-router-dom';

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

export default function Mytripslaptop() {
    const [userName, setUserName] = useState(null);
    const [userPfp, setUserPfp] = useState(null);
    const [user, setUser] = useState('');
    const [loading, setLoading] = useState(true);
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
    useEffect(() => {
        if (!user) return;

        const fetchUserDetails = async () => {
            setLoading(true);
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
            } finally {
                setLoading(false);
            }
        };

        fetchUserDetails();
    }, [user]);
    const [tripid, settripid] = useState([]);
    useEffect(() => {
        const fetchridedetails = async () => {
            try {
                const docref = doc(db, 'Booking IDs', user);
                const docSnap = await getDoc(docref);
                if (docSnap.exists()) {
                    settripid(docSnap.data()['IDs']);
                }
            } catch (error) {

            }
        }
        fetchridedetails();
    }, [])
    useEffect(() => {
        document.title = 'Request a Ride with VistaRide';
    }, []);
    return (
        <div className='webbody'>
            <div className="ehfjfv" style={{ display: 'flex', justifyContent: 'space-between' }}>
                <Link to={'/go/home'}>
                    <div className="hfejfw" >
                        <svg width="100" height="30" xmlns="http://www.w3.org/2000/svg"><rect width="100" height="30" fill="black" rx="5"></rect><text x="50%" y="50%" font-family="'Lobster', cursive" font-size="21" fill="white" text-anchor="middle" alignment-baseline="middle" dominant-baseline="middle">VistaRide</text></svg>
                    </div>
                </Link>
                <div className="hfejfw" style={{ right: '100px', position: 'absolute', flexDirection: 'row', gap: '20px' }}>
                    <Link style={{ textDecoration: 'none', color: "white" }} >
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
                    <img src="https://d3i4yxtzktqr9n.cloudfront.net/riders-web-v2/853ebe0d95a62aca.svg" alt="" width={'100%'} style={{ borderRadius: '10px' }} />
                    <div className="dnvjnv">
                        Past
                    </div>
                    <div className="rnjnfjvn" style={{marginTop:'40px'}}>
                        {Array(tripid.length).fill().map((_, index) => (
                            <Link style={{textDecoration:'none',color:'black'}}>
                            <div key={index} className="tripdetails">
                                
                                </div>
                            </Link>
                        ))}

                    </div>
                </div>
            </div>
        </div>
    )
}
