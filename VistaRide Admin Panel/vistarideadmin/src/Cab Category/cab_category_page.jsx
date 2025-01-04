import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker, DirectionsRenderer } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, doc, onSnapshot, collection, updateDoc } from 'firebase/firestore';
import { useParams } from 'react-router-dom';
import Switch from "react-switch";

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
    const [loading, setLoading] = useState(true); // Add loading state

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Cab Categories'),
            (snapshot) => {
                // console.log('Cab Categories', snapshot.docs.map(doc => doc.data()['Cab Category Status']));
                setcancategoryname(snapshot.docs.map(doc => doc.data()['Cab Category Name']));
                setcancategoryimg(snapshot.docs.map(doc => doc.data()['Cab Category Images']));
                setcancategorydesc(snapshot.docs.map(doc => doc.data()['Cab Category Description']));
                setcancategorystatus(snapshot.docs.map(doc => doc.data()['Cab Category Status']));
                setLoading(false); // Data is fetched, stop loading
            });

        return () => unsubscribe();
    }, []);

    // Circular loading spinner component
    const LoadingSpinner = () => (
        <div className="loading-spinner">
            <div className="spinner"></div>
        </div>
    );

    // Render loading spinner until data is fetched
    if (loading) {
        return <LoadingSpinner />;
    }

    // Handle the toggle switch change
    const handleToggleChange = async(checked, index) => {
        const updatedStatus = [...cabcategorystatus];
        updatedStatus[0][index] = checked; // Toggle the status at the specific index
        setcancategorystatus(updatedStatus); // Update state with new status
        console.log(updatedStatus);
        try {
            const categorydocref=doc(db, 'Cab Categories', 'Category Details');
            await updateDoc(categorydocref, {
                'Cab Category Status': updatedStatus
            });
        } catch (error) {
            console.error('Error updating cab category status', error);
            
        }
    };

    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">Cab Categories</div>
                <div className="divider"></div>
                <div className="jnjnkf">
                    {cabcategorydesc[0].map((name, index) => (
                        <div className="nefnnvjfvn" key={index}>
                            <div className="jdnvjnf" style={{ display: 'flex', flexDirection: 'row' }}>
                                <img src={cabcategoryimg[0][index]} alt="" height={index == 5 ? 65 : 80} width={index == 5 ? 85 : null} style={{ margin: '10px' }} />
                                <div className="jenjnfv" style={{ marginTop: '40px', color: 'grey', fontWeight: '500', display: 'flex', flexDirection: 'row', justifyContent: 'space-between', width: '100%', marginRight: '10px' }}>
                                    {cabcategoryname[0][index]}
                                    {/* Create a togglebar here */}
                                    <Switch  
                                        checked={cabcategorystatus[0][index]} 
                                        height={20} 
                                        width={40} 
                                        onHandleColor='#FFFFFF' 
                                        onChange={(checked) => handleToggleChange(checked, index)} 
                                    />
                                </div>
                            </div>
                            <div className="jjvnjfnvfn" style={{ marginLeft: '10px', fontSize: '12px', color: 'black', marginTop: index == 5 ? '15px' : '0px' }}>
                                {index == 3 ? 'No description' : cabcategorydesc[0][index]}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}
