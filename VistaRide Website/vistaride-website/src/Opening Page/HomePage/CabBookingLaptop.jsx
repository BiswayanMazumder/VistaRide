import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { GoogleMap, LoadScript, Marker, Polyline } from '@react-google-maps/api';
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth, GoogleAuthProvider, onAuthStateChanged, signInWithPopup } from "firebase/auth";
import { collection, doc, getDoc, getDocs, getFirestore } from "firebase/firestore";
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
const db = getFirestore(app);
// Get Auth instance and Google provider
const auth = getAuth(app);
const googleProvider = new GoogleAuthProvider();
const defaultLatLng = { lat: 22.5660201, lng: 88.3630783 };

export default function CabBookingLaptop() {
    const [user, setUser] = useState('');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [userName, setUsername] = useState(null);
    const [userpfp, setUserpfp] = useState(null);
    useEffect(() => {
        const fetchUserDetails = async () => {
          try {
            const docRef = doc(db, "VistaRide User Details", user);
            const docSnap = await getDoc(docRef);
    
            if (docSnap.exists()) {
              setUsername(docSnap.data()['User Name']);
              setUserpfp(docSnap.data()['Profile Picture']);
            //   console.log(docSnap.data()['User Name'])
            //   console.log(docSnap.data()['Profile Picture']);
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
      }, []);
    useEffect(() => {
        onAuthStateChanged(auth, (user) => {
            if (user) {
              
              const uid = user.uid;
              setUser(user.uid);
              // ...
            } else {
                window.location.replace('/');
            }
          });
    });
    useEffect(() => {
        document.title='Request a Ride with VistaRide'
    });
  return (
    <div className='webbody'>
      <div className="ehfjfv" style={{display:'flex',justifyContent:'space-between'}}>
                <div className="hfejfw">
                    VistaRide
                </div>
                <div className="hfejfw" style={{right:'100px',position:'absolute',flexDirection:'row',gap:'20px'}}>
                    <div className="dkf">
                    {userName}
                    </div>
                    <div className="jnjvndv">
                        <img src={userpfp} alt="" height={'45px'} width={'45px'} style={{borderRadius:'50%'}} />
                    </div>
                </div>
            </div>
    </div>
  )
}
