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

export default function Cab_category_page() {
    const [cabcategoryname, setcancategoryname] = useState([]);
    const [cabcategoryimg, setcancategoryimg] = useState([]);
    const [cabcategorydesc, setcancategorydesc] = useState([]);
    const [newcategory, setnewcategory] = useState(false);
    const [cabcategorystatus, setcancategorystatus] = useState([]);
    const [loading, setLoading] = useState(true); // Add loading state
    const [previewImage, setPreviewImage] = useState(null);
    const [categoryname, setcatergoryname] = useState('');
    const [categorydesc, setcategorydesc] = useState('');
    const [imageconfirmed, setimageconfirmed] = useState(false);
    const handleImageChange = (event) => {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                setPreviewImage(reader.result);
            };
            reader.readAsDataURL(file);
        }
    };
    const [imageURL, setimageURL] = useState('');
    const handleImageUpload = async () => {
        if (!previewImage) return;

        try {
            // Create a storage reference
            const storage = getStorage();
            const imageRef = ref(storage, `cab-category-images/${categoryname}-${Date.now()}`);

            // Upload the image as a base64 string
            await uploadString(imageRef, previewImage, 'data_url');

            // Get the download URL of the uploaded image
            const imageUrl = await getDownloadURL(imageRef);

            // Print the download URL in the console
            setimageURL(imageUrl);

            // console.log('Image uploaded successfully. Download URL:', imageUrl);

            // Mark image as confirmed
        } catch (error) {
            console.error('Error uploading image to Firebase Storage', error);
        }
    };
    const handlenewcategory = async () => {
        try {
            cabcategoryimg[0].push(imageURL);
            cabcategorydesc[0].push(categorydesc);
            cabcategoryname[0].push(categoryname);
            cabcategorystatus[0].push(false);
            // console.log(cabcategorydesc[0], cabcategoryimg, cabcategoryname, cabcategorystatus);
            const categorydocref = doc(db, 'Cab Categories', 'Category Details');
            await updateDoc(categorydocref, {
                'Cab Category Name': cabcategoryname[0],
                'Cab Category Description': cabcategorydesc[0],
                'Cab Category Images': cabcategoryimg[0],
                'Cab Category Status': cabcategorystatus[0]
            });
            setnewcategory(false);
        } catch (error) {

        }
    }
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

    const handleCategoryNameChange = (event) => {
        setcatergoryname(event.target.value); // Update category name state
    };

    const handleCategoryDescChange = (event) => {
        setcategorydesc(event.target.value); // Update category description state
    };
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
    const handleToggleChange = async (checked, index) => {
        const updatedStatus = [...cabcategorystatus];
        updatedStatus[0][index] = checked; // Toggle the status at the specific index
        setcancategorystatus(updatedStatus); // Update state with new status
        // console.log(updatedStatus[0]);
        try {
            const categorydocref = doc(db, 'Cab Categories', 'Category Details');
            await updateDoc(categorydocref, {
                'Cab Category Status': updatedStatus[0]
            });
        } catch (error) {
            console.error('Error updating cab category status', error);

        }
    };

    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv" style={{ width: '90%', display: 'flex', flexDirection: 'row', justifyContent: 'space-between', position: 'relative' }}>{newcategory ? 'Add Cab Category' : 'Cab Categories'}
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jikd" style={{ fontSize: '15px', marginTop: '15px', display: 'flex', flexDirection: 'row', alignItems: 'center' }} onClick={() => setnewcategory(!newcategory)}>
                            {newcategory ? (<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <line x1="4" y1="4" x2="16" y2="16" />
                                <line x1="16" y1="4" x2="4" y2="16" />
                            </svg>
                            ) : (<svg width="10" height="10" viewBox="0 0 50 50" xmlns="http://www.w3.org/2000/svg">
                                <rect x="22" y="0" width="6" height="50" fill="black" />
                                <rect x="0" y="22" width="50" height="6" fill="black" />
                            </svg>)}
                            <div style={{ marginLeft: '10px' }}>{newcategory ? 'Close' : 'Add'}</div>
                        </div>
                    </Link>
                </div>
                <div className="divider"></div>
                {newcategory ? <div className="jnjnkf" style={{ display: 'flex', flexDirection: 'column' }}>
                    <div className="jdhvjhdv" style={{ width: '50vw' }}>
                        Cab Category Image
                    </div>
                    <div className="jnjvnfjb">
                        {imageconfirmed ? <></> : (<input
                            type="file"
                            accept="image/*"
                            onChange={(event) => {
                                const file = event.target.files[0];
                                if (file) {
                                    const reader = new FileReader();
                                    reader.onload = () => {
                                        setPreviewImage(reader.result); // Set the preview image
                                    };
                                    reader.readAsDataURL(file);
                                }
                            }}
                        />)}
                        {previewImage && (
                            <div style={{ marginTop: '10px', display: 'flex', flexDirection: 'column', alignItems: 'center', display: 'flex', flexDirection: 'row', gap: '20px' }}>
                                <img
                                    src={previewImage}
                                    alt="Preview"
                                    height={imageconfirmed ? 80 : 50}
                                    width={imageconfirmed ? 80 : 50}
                                    style={{ border: '1px solid #ccc', borderRadius: '5px', marginBottom: '10px' }}
                                />
                                {imageconfirmed ? <></> : (<button
                                    onClick={() => {
                                        handleImageUpload();
                                        setimageconfirmed(true)
                                    }}
                                    style={{
                                        backgroundColor: '#4CAF50',
                                        color: 'white',
                                        padding: '8px 16px',
                                        border: 'none',
                                        borderRadius: '4px',
                                        cursor: 'pointer',
                                    }}
                                >
                                    Confirm Image
                                </button>)}
                            </div>
                        )}
                    </div>
                    <div className="jdhvjhdv">
                        Cab Category Name
                    </div>

                    <div className="jnjvnfjb">
                        <input
                            type="text"
                            placeholder="Cab Category Name"
                            className='searchinput'
                            style={{ marginTop: '-10px', width: '100%', height: '50px' }}
                            value={categoryname}
                            onChange={handleCategoryNameChange}
                        /></div>
                    <div className="jdhvjhdv">
                        Cab Category Description
                    </div>
                    <div className="jnjvnfjb">
                        <input
                            type="text"
                            placeholder="Cab Category Description"
                            className='searchinput'
                            style={{ marginTop: '-10px', width: '100%', height: '50px' }}
                            value={categorydesc}
                            onChange={handleCategoryDescChange}
                        /></div>
                    <div className="jnjvnfjb">
                        <div className="jnfkvkfv" style={{ backgroundColor: imageconfirmed != false && categoryname != '' && categorydesc != '' ? 'rgb(120, 120, 217)' : 'grey', color: 'white', cursor: imageconfirmed != false && categoryname != '' && categorydesc != '' ? 'pointer' : 'not-allowed', justifyContent: 'center', display: 'flex', alignItems: 'center', width: '100%', height: '50px' }} onClick={imageconfirmed != false && categoryname != '' && categorydesc != ''?handlenewcategory:null}>
                            Add new Category
                        </div>
                    </div>
                </div> : (<div className="jnjnkf">
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
                </div>)}
            </div>
        </div>
    );
}
