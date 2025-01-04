import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker, DirectionsRenderer } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, doc, onSnapshot, collection } from 'firebase/firestore';
import { useParams } from 'react-router-dom';

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

export default function Cab_category_page() {
    const [cabcategoryname, setcancategoryname] = useState([]);
    const [cabcategoryimg, setcancategoryimg] = useState([]);
    const [cabcategorydesc, setcancategorydesc] = useState([]);
    const [cabcategorystatus, setcancategorystatus] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Cab Categories'),
            (snapshot) => {
                console.log(snapshot.docs.map(doc => doc.data()['Cab Category Description']));
                setcancategoryname(snapshot.docs.map(doc => doc.data()['Cab Category Name']));
                setcancategoryimg(snapshot.docs.map(doc => doc.data()['Cab Category Images']));
                setcancategorydesc(snapshot.docs.map(doc => doc.data()['Cab Category Description']));
                setcancategorystatus(snapshot.docs.map(doc => doc.data()['Cab Category Status']));
            });
        return () => unsubscribe();

    }, []);
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">Cab Categories</div>
                <div className="divider"></div>
                <div className="jnjnkf">
                    {cabcategorydesc[0].map((name, index) => (
                        <div className="nefnnvjfvn" key={index}>
                            <div className="jdnvjnf" style={{ display: 'flex', flexDirection: 'row' }}>
                                <img src={cabcategoryimg[0][index]} alt="" height={index == 5 ? 65 : 80} width={index == 5 ? 85 : null} style={{ margin: '10px' }} />
                                <div className="jenjnfv" style={{ marginTop: '40px', color: 'grey', fontWeight: '500' }}>
                                    {cabcategoryname[0][index]}
                                </div>
                            </div>
                            <div className="jjvnjfnvfn" style={{marginLeft:'10px',fontSize:'12px',color:'black',marginTop:index==5?'15px':'0px'}}>
                            {index==3?'No description':cabcategorydesc[0][index]}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}
