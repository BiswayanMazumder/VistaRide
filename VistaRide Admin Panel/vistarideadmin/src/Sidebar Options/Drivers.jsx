import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, getDoc, doc } from 'firebase/firestore';
import { Link } from 'react-router-dom';
import { jsPDF } from 'jspdf';
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

export default function Drivers() {
    const [drivers, setDrivers] = useState([]);
        useEffect(() => {
            const unsubscribe = onSnapshot(
                collection(db, 'VistaRide Driver Details'),
                (snapshot) => {
                    const driverList = snapshot.docs
                        .map((doc) => doc.data())    
                    setDrivers(driverList); // Update the state with driver data
                    console.log('Drivers Avaliable', driverList)
                },
                (error) => {
                    console.error('Error fetching drivers: ', error);
                }
            );
    
            // Cleanup listener on unmount
            return () => unsubscribe();
        }, []);
  return (
    <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
      <div className="jnvjfnjf">
        <div className="jffbvfjv">
            Drivers
        </div>
        <div className="divider"></div>
        <div className="jnjvnfjb">
            
        </div>
      </div>
    </div>
  )
}
