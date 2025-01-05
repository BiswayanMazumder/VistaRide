import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, doc, updateDoc } from 'firebase/firestore';
import { Link } from 'react-router-dom';

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
export default function Driverapproval() {
    const [drivers, setDrivers] = useState([]);
        useEffect(() => {
            const unsubscribe = onSnapshot(
                collection(db, 'VistaRide Driver Details'),
                (snapshot) => {
                    const driverList = snapshot.docs.map((doc) => doc.data());
                    setDrivers(driverList); // Update the state with driver data
                },
                (error) => {
                    console.error('Error fetching drivers: ', error);
                }
            );
    
            return () => unsubscribe();
        }, []);
        const updateDriverApproval = async (isApproved, driverID) => {
                const docRef = doc(db, 'VistaRide Driver Details', driverID);
                await updateDoc(docRef, { Approved: !isApproved });
            };
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    Driver Approval
                </div>
                <div className="divider"></div>
                <div className="jnjvnfjb">
                    <h4>Search:</h4>
                    <input
                        type="text"
                        placeholder="Search for drivers"
                        className='searchinput'
                        // value={searchedText}
                        // onChange={handleInputChange}
                    />
                    {/* <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jfnvjnfb">
                            SEARCH
                        </div>
                    </Link> */}
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jfnvjnfb" >
                            RESET
                        </div>
                    </Link>
                </div>
                <div className="knjfnbnf">
                <table style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse', border: '1px solid #e0e0e0',fontSize: '12px' }}>
                <thead style={{ fontWeight: '300' }}>
                            <tr>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Profile Picture</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Name</th>
                                
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driving Licence (Front)</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driving Licence (Back)</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Registration Certificate (Front)</th>
                                <th style={{ fontWeight: '300', padding: '10px -10px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Registration Certificate (Back)</th>
                                <th style={{ fontWeight: '400', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driving Licence Number</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Car Category - Car Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver's Selfie</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Actions</th>
                            </tr>
                        </thead>
                        <tbody style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
                            {
                                drivers.map((ride, index) => (
                                    <tr key={index}>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><img src={ride['Profile Picture'] == null || ride['Profile Picture'] == '' ? 'https://cdn-icons-png.flaticon.com/512/149/149071.png' : ride['Profile Picture']} height={'50px'} width={'50px'} style={{ borderRadius: '50%' }}></img></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Name']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Back Side DL']!=null?(<a href={ride['Back Side DL']} target='_blank'>View Document</a>):'No Documents Uploaded'}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Front Side DL']!=null?(<a href={ride['Front Side DL']} target='_blank'>View Document</a>):'No Documents Uploaded'}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Front Side RC']!=null?(<a href={ride['Front Side RC']} target='_blank'>View Document</a>):'No Documents Uploaded'}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Back Side RC']!=null?(<a href={ride['Back Side RC']} target='_blank'>View Document</a>):'No Documents Uploaded'}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Driving Licence Number']!=null?(ride['Driving Licence Number']):'No Licence Number Uploaded'}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Car Category']!=null?(ride['Car Category']):'No details found'} - {ride['Car Name']!=null?(ride['Car Name']):'No details found'} ({ride['Car Number Plate']!=null?(ride['Car Number Plate']):'No details found'})</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><img src={ride['Driver Selfie'] == null || ride['Driver Selfie'] == '' ? 'https://cdn-icons-png.flaticon.com/512/149/149071.png' : ride['Driver Selfie']} height={'50px'} width={'50px'} style={{ borderRadius: '50%' }}></img></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        <div onClick={() => updateDriverApproval(ride['Approved'], ride['Driver ID'])} style={{ cursor: 'pointer', display: 'flex', flexDirection: 'row', gap: '10px', fontSize: '10px' }}>
                                            {ride['Ride Doing']==null? ride['Submitted']? !ride['Approved'] ? (<img src='https://cdn-icons-png.flaticon.com/512/190/190411.png' height={20} width={20} />) : (<img src='   https://cdn-icons-png.flaticon.com/512/1828/1828843.png ' //approved driver
                                                height={20} width={20}
                                            ></img>):<></>:<></>}
                                            {ride['Ride Doing']==null? ride['Submitted']? !ride['Approved'] ? 'Approve Driver' : 'Reject Driver':'No Actions Required':'Cannot do any action as driver is already on  a trip'}
                                        </div>
                                    </td>
                                    </tr>
                                    
                                ))
                            }
                        </tbody>
                </table>
                </div>
            </div>
        </div>
    )
}
