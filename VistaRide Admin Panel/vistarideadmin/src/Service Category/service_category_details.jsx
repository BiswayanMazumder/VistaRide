import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import Switch from "react-switch";
import { initializeApp } from 'firebase/app';
import { getFirestore, doc, onSnapshot, collection, updateDoc } from 'firebase/firestore';

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
    const [servicename, setservicename] = useState('');
    const [description, setdescription] = useState('');
    const [newcategory, setnewcategory] = useState(false);

    // Fetch data from Firebase
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
        const updatedStatus = [...categorystatus];
        updatedStatus[0][index] = checked; // Update status at the specific index
        // console.log(updatedStatus);
        setcategorystatus(updatedStatus); // Update state with new status

        try {
            const categorydocref = doc(db, 'Service Categories', 'Categories');
            await updateDoc(categorydocref, {
                'Category Status': updatedStatus[0]
            });
        } catch (error) {
            console.error('Error updating category status', error);
        }
    };

    const handleServiceChange = (event) => {
        setservicename(event.target.value); // Update category name state
    };

    const handleServiceDescChange = (event) => {
        setdescription(event.target.value); // Update category description state
    };

    const handlenewcategory = async () => {
        try {
            categorynames[0].push(servicename);
            categorydescriptions[0].push(description);
            categorystatus[0].push(false); // Set initial status to false for all new categories

            const categorydocref = doc(db, 'Service Categories', 'Categories');
            await updateDoc(categorydocref, {
                'Category Descriptions': categorydescriptions[0],
                'Category Names': categorynames[0],
                'Category Status': categorystatus[0]
            });

            setnewcategory(false); // Close the add new category form
        } catch (error) {
            console.error('Error adding new category', error);
        }
    };

    if (loading) {
        return <div>Loading...</div>; // Show a loading state while data is fetched
    }

    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv" style={{ width: '90%', display: 'flex', flexDirection: 'row', justifyContent: 'space-between', position: 'relative' }}>
                    {'Service Category'}
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jikd" style={{ fontSize: '15px', marginTop: '15px', display: 'flex', flexDirection: 'row', alignItems: 'center' }} onClick={() => setnewcategory(!newcategory)}>
                            {newcategory ? (
                                <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                    <line x1="4" y1="4" x2="16" y2="16" />
                                    <line x1="16" y1="4" x2="4" y2="16" />
                                </svg>
                            ) : (
                                <svg width="10" height="10" viewBox="0 0 50 50" xmlns="http://www.w3.org/2000/svg">
                                    <rect x="22" y="0" width="6" height="50" fill="black" />
                                    <rect x="0" y="22" width="50" height="6" fill="black" />
                                </svg>
                            )}
                            <div style={{ marginLeft: '10px' }}>{newcategory ? 'Close' : 'Add'}</div>
                        </div>
                    </Link>
                </div>
                <div className="divider"></div>
                {newcategory ? (
                    <div className="jnjnkf" style={{ display: 'flex', flexDirection: 'column' }}>
                        <div className="jdhvjhdv" style={{ width: '50vw' }}>
                            Service Category Name
                        </div>
                        <div className="jnjvnfjb">
                            <input
                                type="text"
                                placeholder="Service Category Name"
                                className="searchinput"
                                style={{ marginTop: '-10px', width: '100%', height: '50px' }}
                                value={servicename}
                                onChange={handleServiceChange}
                            />
                        </div>
                        <div className="jdhvjhdv" style={{ width: '50vw' }}>
                            Service Category Description
                        </div>
                        <div className="jnjvnfjb">
                            <input
                                type="text"
                                placeholder="Service Category Description"
                                className="searchinput"
                                style={{ marginTop: '-10px', width: '100%', height: '50px' }}
                                value={description}
                                onChange={handleServiceDescChange}
                            />
                        </div>
                        <div className="jnjvnfjb" style={{ marginBottom: '20px' }}>
                            <div
                                className="jnfkvkfv"
                                style={{
                                    backgroundColor: servicename !== '' && description !== '' ? 'rgb(120, 120, 217)' : 'grey',
                                    color: 'white',
                                    cursor: servicename !== '' && description !== '' ? 'pointer' : 'not-allowed',
                                    justifyContent: 'center',
                                    display: 'flex',
                                    alignItems: 'center',
                                    width: '100%',
                                    height: '50px',
                                }}
                                onClick={servicename !== '' && description !== '' ? handlenewcategory : null}
                            >
                                Add new Service
                            </div>
                        </div>
                    </div>
                ) : (
                    <div className="jnjnkf">
                        {categorynames[0].map((name, index) => (
                            <div className="nefnnvjfvn" key={index}>
                                <div className="jdnvjnf" style={{ display: 'flex', flexDirection: 'row' }}>
                                    <img
                                        src="https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png"
                                        alt=""
                                        height={index === 5 ? 65 : 80}
                                        width={index === 5 ? 85 : null}
                                        style={{ margin: '10px' }}
                                    />
                                    <div
                                        className="jenjnfv"
                                        style={{
                                            marginTop: '40px',
                                            color: 'grey',
                                            fontWeight: '500',
                                            display: 'flex',
                                            flexDirection: 'row',
                                            justifyContent: 'space-between',
                                            width: '100%',
                                            marginRight: '10px',
                                            fontSize: '15px',
                                        }}
                                    >
                                        {categorynames[0][index]}
                                        <Switch
                                            checked={categorystatus[0][index]}
                                            height={20}
                                            width={40}
                                            onHandleColor="#FFFFFF"
                                            onChange={(checked) => handleToggleChange(checked, index)}
                                        />
                                    </div>
                                </div>
                                <div
                                    className="jjvnjfnvfn"
                                    style={{
                                        marginLeft: '10px',
                                        fontSize: '12px',
                                        color: 'black',
                                        marginTop: index === 5 ? '15px' : '0px',
                                    }}
                                >
                                    {categorydescriptions[0][index]}
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
