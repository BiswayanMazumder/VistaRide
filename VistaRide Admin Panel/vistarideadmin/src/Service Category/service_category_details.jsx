import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker, DirectionsRenderer } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, doc, onSnapshot, collection, updateDoc } from 'firebase/firestore';
import { Link, useParams } from 'react-router-dom';
import Switch from "react-switch";
import { getStorage, ref, uploadString, getDownloadURL } from 'firebase/storage';
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

export default function Service_category_details() {
    const [categorystatus, setcategorystatus] = useState([]);
    const [categorynames, setcategorynames] = useState([]);
    const [categorydescriptions, setcategorydescriptions] = useState([]);
    const [loading, setLoading] = useState(true);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Service Categories'),
            (snapshot) => {
                setcategorynames(snapshot.docs.map(doc => doc.data()['Category Names']));
                setcategorystatus(snapshot.docs.map(doc => doc.data()['Category Status']));
                setcategorydescriptions(snapshot.docs.map(doc => doc.data()['Category Descriptions']));
                setLoading(false); // Data is fetched, stop loading
            });

        return () => unsubscribe();
    }, []);
    const handleToggleChange = async (checked, index) => {
        console.log(`Toggling index: ${index}, checked: ${checked}`);
        const updatedStatus = [...categorystatus];
        updatedStatus[0][index] = checked; // Toggle the status at the specific index
        setcategorystatus(updatedStatus); // Update state with new status
        try {
            const categorydocref = doc(db, 'Service Categories', 'Categories');
            await updateDoc(categorydocref, {
                'Category Status': updatedStatus[0]
            });
        } catch (error) {
            console.error('Error updating cab category status', error);
        }
    };
    
    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv" style={{ width: '90%', display: 'flex', flexDirection: 'row', justifyContent: 'space-between', position: 'relative' }}>
                    {'Service Category'}
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jikd" style={{ fontSize: '15px', marginTop: '15px', display: 'flex', flexDirection: 'row', alignItems: 'center' }}>
                            {(<svg width="10" height="10" viewBox="0 0 50 50" xmlns="http://www.w3.org/2000/svg">
                                <rect x="22" y="0" width="6" height="50" fill="black" />
                                <rect x="0" y="22" width="50" height="6" fill="black" />
                            </svg>)}
                            <div style={{ marginLeft: '10px' }}>{'Add'}</div>
                        </div>
                    </Link>

                </div>
                <br /><br />
                <div className="jnjnkf">
                    {categorynames.map((name, index) => (
                        <div className="nefnnvjfvn" key={index}>
                            <div className="jdnvjnf" style={{ display: 'flex', flexDirection: 'row' }}>
                                <img src='https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png' alt="" height={index == 5 ? 65 : 80} width={index == 5 ? 85 : null} style={{ margin: '10px' }} />
                                <div className="jenjnfv" style={{ marginTop: '40px', color: 'grey', fontWeight: '500', display: 'flex', flexDirection: 'row', justifyContent: 'space-between', width: '100%', marginRight: '10px',fontSize:'15px' }}>
                                    {categorynames[index]}
                                    {/* Create a togglebar here */}
                                    <Switch
                                        checked={categorystatus[0][index]}
                                        height={20}
                                        width={40}
                                        onHandleColor='#FFFFFF'
                                        onChange={(checked) => handleToggleChange(checked, index)}
                                    />
                                </div>
                            </div>
                            <div className="jjvnjfnvfn" style={{ marginLeft: '10px', fontSize: '12px', color: 'black', marginTop: index == 5 ? '15px' : '0px' }}>
                                {categorydescriptions[index]}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}
