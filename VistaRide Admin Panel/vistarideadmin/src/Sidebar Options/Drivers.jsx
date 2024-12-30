import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, getDoc, doc, updateDoc } from 'firebase/firestore';
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
    const [driverID,setDriverID] = useState([]);
    const updatedriverapproval=async(isapproved,driverID)=>{
        if(isapproved){
            const docRef = doc(db, 'VistaRide Driver Details', driverID);
            await updateDoc(docRef, { Approved: false },);
        }
        if(!isapproved){
            const docRef = doc(db, 'VistaRide Driver Details', driverID);
            await updateDoc(docRef, { Approved: true },);
        }
    }
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
    const [searchedText, setSearchedText] = useState('');
    const handleInputChange = (event) => {
        setSearchedText(event.target.textContent); // update the state with typed content
    };
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    Drivers
                </div>
                <div className="divider"></div>
                <div className="jnjvnfjb">
                    <h4>Search:</h4>
                    <input type="text" placeholder="Search for drivers" className='searchinput' contentEditable
                        onInput={handleInputChange}
                        suppressContentEditableWarning={true} />
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jfnvjnfb">
                            SEARCH
                        </div>

                    </Link>
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jfnvjnfb" onClick={() => {
                            setSearchedText('');
                        }}>
                            RESET
                        </div>
                    </Link>

                </div>
                <div className="knjfnbnf">
                    <table style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse', border: '1px solid #e0e0e0' }}>
                        <thead style={{ fontWeight: '300' }}>
                            <tr>
                                
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Email</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Vehicle Category-Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Contact Number</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>View/Edit Documents</th>
                                <th style={{ fontWeight: '300', padding: '10px -10px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Status</th>
                                <th style={{ fontWeight: '400', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Location</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Actions</th>
                            </tr>
                        </thead>
                        <tbody style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
                            {drivers.map((ride, index) => (
                                <tr key={index}>
                                    
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Name']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Email Address']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Car Category']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><a href={`tel:${ride['Contact Number']}`}>{ride['Contact Number']}</a></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><a href='#'>View Documents</a></td>
                                    <td style={{
                                        padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0', color: ride['Driver Online'] && ride['Driver Avaliable'] ? 'green' : ride['Driver Online'] && ride['Driver Avaliable'] === false ? 'grey' : 'red',
                                        fontWeight: ride['Driver Online'] && ride['Driver Avaliable'] ? '600' : ride['Driver Online'] && ride['Driver Avaliable'] === false ? '600' : 'normal'
                                    }}>
                                        {ride['Driver Online'] && ride['Driver Avaliable'] ? 'Online' : ride['Driver Online'] && ride['Driver Avaliable'] === false ? 'In a ride' : 'Offline'}
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><a href={`https://www.google.com/maps?q=${ride['Current Latitude']},${ride['Current Longitude']}`} target="_blank">Locate Driver</a></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0', }}>
                                        {!ride['Approved'] ?<div onClick={()=>updatedriverapproval(false,ride['Driver ID'])} style={{cursor:'pointer'}}>
                                            <img src='   https://cdn-icons-png.flaticon.com/512/190/190411.png ' //driver not approved
                                            height={20} width={20}
                                        ></img>
                                        {/* <img src='      https://cdn-icons-png.flaticon.com/512/1828/1828843.png  '
                                            height={20} width={20} style={{marginLeft:'20px'}}
                                        ></img> */}
                                        </div> : <div onClick={()=>updatedriverapproval(true,ride['Driver ID'])} style={{cursor:'pointer'}}>
                                            
                                        <img src='   https://cdn-icons-png.flaticon.com/512/1828/1828843.png ' //approved driver
                                            height={20} width={20} 
                                        ></img>
                                        </div>}

                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>


                </div>
            </div>
        </div>
    )
}
