import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, getDoc, doc } from 'firebase/firestore';
import { Link } from 'react-router-dom';
import { jsPDF } from 'jspdf';
import { getAuth, onAuthStateChanged } from 'firebase/auth';
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
const auth = getAuth(app);
export default function Dashboard() {
    const [selectedIndex, setSelectedIndex] = useState(0);
    const [currentLocation, setCurrentLocation] = useState(null);
        const [firstname,setFirstname]=useState('');
        const [lastname,setLastname]=useState('');
        useEffect(() => {
            // Create an async function inside the useEffect
            const checkUserAuthState = async () => {
              onAuthStateChanged(auth, async (user) => {
                if (user) {
                  // User is signed in
                  const uid = user.uid;
                  const userDocRef = doc(db, "Admin Details", uid);
                  try {
                    const userDocSnapshot = await getDoc(userDocRef);
                    if (userDocSnapshot.exists()) {
                      // Handle the user document snapshot
                      const userData = userDocSnapshot.data();
                    //   console.log('User Data:', userData);
                    setFirstname(userData.firstName);
                    setLastname(userData.lastName);
                    
                    } else {
                      console.log('No such document!');
                    }
                  } catch (error) {
                    console.error("Error fetching document:", error);
                  }
                } else {
                  // User is signed out
                  window.location.replace('/');
                }
              });
            };
          
            // Call the async function
            checkUserAuthState();
          
            // Optionally, you can clean up if needed
            return () => {
              // Cleanup if needed
            };
          }, []);
    const [mapContainerStyle, setMapContainerStyle] = useState({
        width: '100%',
        height: '100%',
    });
    const [drivers, setDrivers] = useState([]); // Store driver data
    const [unavaliabledrivers, setunavaliableDrivers] = useState([]); // Store driver data
    const [ridedoingdrivers, setridedoingDrivers] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (driver) => driver['Driver Online'] && driver['Driver Avaliable']
                    ); // Only drivers that are online and available

                setDrivers(driverList); // Update the state with driver data
                // console.log('Drivers Avaliable', driverList)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (driver) => driver['Driver Online'] == false || driver['Driver Avaliable'] == false
                    ); // Only drivers that are online and available

                setunavaliableDrivers(driverList); // Update the state with driver data
                // console.log('Drivers Unavaliable',driverList)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (driver) => driver['Driver Online'] && driver['Ride Doing'] != null
                    ); // Only drivers that are online and available

                setridedoingDrivers(driverList); // Update the state with driver data
                // console.log('Drivers Ride Doing', driverList)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [riders, setriders] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide User Details'),
            (snapshot) => {
                const riderlist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['User Name'] != null
                    ); // Only drivers that are online and available

                setriders(riderlist); // Update the state with driver data
                // console.log('Riders', riderlist)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [totalrides, settotalrides] = useState([]);
    const [drivernames, setDrivernames] = useState([]); // Store driver details in an array
    const [ridernames, setridernames] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Driver ID'] != null && rider['Ride Owner'] != null && rider['Driver ID'] != '' && rider['Ride Owner'] != ''
                    ); // Only drivers that are online and available

                settotalrides(rideslist); // Update the state with ride data
                // console.log('Rides', rideslist);

                // Fetch the driver's name for each ride in the rideslist
                const driverNamesArray = []; // Initialize an empty array for storing driver names
                const driverMap = {}; // Object to map driverId to driverName
                const riderNamesArray = []; // Initialize an empty array for storing driver names
                const riderMap = {}; // Object to map driverId to driverName
                rideslist.forEach(async (ride) => {
                    const driverId = ride['Driver ID'];
                    if (driverId) {
                        // Fetch the driver's name from VistaRide Driver Details collection
                        try {
                            const driverDocRef = doc(db, 'VistaRide Driver Details', driverId);
                            const driverDocSnap = await getDoc(driverDocRef);

                            if (driverDocSnap.exists()) {
                                const driverData = driverDocSnap.data();

                                const driverName = driverData['Name']; // Assuming the driver's name is stored in the 'Name' field
                                driverNamesArray.push(driverName);
                                // Store driver name in the map
                                driverMap[driverId] = driverName;
                                // console.log('Driver Data', driverNamesArray);
                                // Once all names are fetched, update the state
                                setDrivernames(driverNamesArray);
                            } else {
                                console.log('No such driver found for ID:', driverId);
                            }
                        } catch (error) {
                            console.error('Error fetching driver name: ', error);
                        }
                    }
                });
                rideslist.forEach(async (ride) => {
                    const riderID = ride['Ride Owner'];
                    if (riderID) {
                        // Fetch the driver's name from VistaRide Driver Details collection
                        try {
                            const driverDocRef = doc(db, 'VistaRide User Details', riderID);
                            const driverDocSnap = await getDoc(driverDocRef);

                            if (driverDocSnap.exists()) {
                                const driverData = driverDocSnap.data();

                                const riderName = driverData['User Name']; // Assuming the driver's name is stored in the 'Name' field
                                riderNamesArray.push(riderName);
                                // Store driver name in the map
                                riderMap[riderID] = riderName;
                                // console.log('Driver Data', driverNamesArray);
                                // Once all names are fetched, update the state
                                setridernames(riderNamesArray);
                            } else {
                                console.log('No such driver found for ID:', riderID);
                            }
                        } catch (error) {
                            console.error('Error fetching driver name: ', error);
                        }
                    }
                });
            },
            (error) => {
                console.error('Error fetching rides: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [completedrides, setcompletedrides] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Driver ID'] != null && rider['Ride Owner'] != null && rider['Ride Completed']
                    ); // Only drivers that are online and available

                setcompletedrides(rideslist); // Update the state with driver data
                // console.log('Rides', rideslist)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const [cancelledrides, setcancelledrides] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Driver ID'] != null && rider['Ride Owner'] != null && rider['Ride Cancelled']
                    ); // Only drivers that are online and available

                setcancelledrides(rideslist); // Update the state with driver data
                // console.log('Rides', rideslist)
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };
    // Get the current location
    useEffect(() => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    setCurrentLocation({
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                    });
                },
                (error) => {
                    console.error(error);
                }
            );
        }
    }, []);

    // Handle option click to update the selected index
    const handleOptionClick = (index) => {
        setSelectedIndex(index);
    };
    function createReceipt(
        cabCategory,
        bookingId,
        pickupLocation,
        dropLocation,
        fare,
        driverName,
        riderName,
        travelDistance,
        travelTime
      ) {
        // Create a new jsPDF instance
        const doc = new jsPDF();
      
        // Receipt header
        doc.setFontSize(16);
        doc.text('VistaRide Receipt', 10, 10);
      
        // Receipt body
        doc.setFontSize(14);
        doc.text(`Thanks for riding, ${riderName}`, 10, 30);
        doc.setFontSize(12);
        doc.text("We're glad to have you as a VistaRide Rewards Gold Member.", 10, 40);
      
        // Utility function for text wrapping
        function splitTextToFit(text, width) {
          return doc.splitTextToSize(text, width);
        }
      
        // Ride Details
        doc.setFontSize(12);
        doc.text('Cab Category:', 10, 60);
        doc.text(cabCategory, 80, 60);
        
        doc.text('Booking ID:', 10, 70);
        doc.text(bookingId, 80, 70);
      
        doc.text('Pickup Location:', 10, 80);
        const pickupLocationLines = splitTextToFit(pickupLocation, 180); // 180 is the max width
        doc.text(pickupLocationLines, 80, 80);
      
        doc.text('Drop Location:', 10, 100);
        const dropLocationLines = splitTextToFit(dropLocation, 180); // 180 is the max width
        doc.text(dropLocationLines, 80, 100);
      
        doc.text('Driver Name:', 10, 120);
        doc.text(driverName, 80, 120);
      
        doc.text('Rider Name:', 10, 130);
        doc.text(riderName, 80, 130);
      
        doc.text('Travel Distance:', 10, 140);
        doc.text(travelDistance, 80, 140);
      
        doc.text('Travel Time:', 10, 150);
        doc.text(travelTime, 80, 150);
      
        // Fare
        doc.setFontSize(12);
        doc.text('Total Fare:', 10, 160);
        doc.text(`₹${fare}`, 80, 160);
      
        // Separate rides with a line
        doc.setLineWidth(0.5);
        doc.line(10, 170, 200, 170); // Draw a line after the details
      
        // Save the PDF with booking ID as filename
        doc.save(`${bookingId}_receipt.pdf`);
      }
      
    const mapCenter = currentLocation;
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="fnjnfjn">
                <div className="menfd">
                    {firstname} {lastname}
                </div>
                <div className="hehfhejfe">
                    Administrator
                </div>
            </div>
            <div className="jjnjnjnv">
                <div className="njdnvv">
                    <div className="jjvnjvnfv">
                        <div className="jndjvnjf">
                            God's View
                        </div>
                        <div className="jdjnjf">
                            <div className="jfhjhjvh" onClick={() => handleOptionClick(0)} style={{ boxShadow: selectedIndex == 0 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex == 0 ? 'black' : 'grey', border: selectedIndex == 0 ? '1px solid black' : null }}>
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/driver_avaliable.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Avaliable
                                    <br /><br />
                                    <center>
                                        ({drivers.length})
                                    </center>

                                </div>
                            </div>
                            <div className="jfhjhjvh" onClick={() => handleOptionClick(1)} style={{ boxShadow: selectedIndex == 1 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex == 1 ? 'black' : 'grey', border: selectedIndex == 1 ? '1px solid black' : null }}>
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/car_not_avaliable.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Not Avaliable
                                    <br /><br />
                                    <center>
                                        ({unavaliabledrivers.length})
                                    </center>
                                </div>
                            </div>
                            <div className="jfhjhjvh" onClick={() => handleOptionClick(2)} style={{ boxShadow: selectedIndex == 2 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null, color: selectedIndex == 2 ? 'black' : 'grey', border: selectedIndex == 2 ? '1px solid black' : null }}>
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/waytopickup.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Ride Doing
                                    <br /><br />
                                    <center>
                                        ({ridedoingdrivers.length})
                                    </center>
                                </div>
                            </div>
                            {/* <div className="jfhjhjvh" onClick={() => handleOptionClick(3)} style={{ boxShadow: selectedIndex == 3 ? '0 4px 6px rgba(0, 0, 0, 0.2)' : null,color:selectedIndex == 3 ?'black':'grey',border:selectedIndex == 3 ?'1px solid black':null }}>
                                <img src='assets/images/waytopickup.png' alt="" height={"80px"} width={"80px"} />
                                <div className="jdjvnj" >
                                    Way to Dropoff
                                    <br /><br />
                                    <center>
                                        (0)
                                    </center>
                                </div>
                            </div> */}
                        </div>
                        <div className="jjnfjnfjvn">
                            <LoadScript
                                googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM"
                                libraries={['places']}
                            >
                                <GoogleMap
                                    mapContainerStyle={mapContainerStyle}
                                    center={mapCenter}
                                    zoom={12}
                                    options={mapOptions}
                                >
                                    {/* You can add markers or other map features if you want */}
                                    {selectedIndex == 0 ? (drivers.map((driver, index) => (
                                        <Marker
                                            key={index}
                                            icon={{
                                                url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea',  // Path to your custom icon
                                                scaledSize: new window.google.maps.Size(50, 50), // Adjust width and height here
                                            }}
                                            position={{
                                                lng: parseFloat(driver['Current Longitude']),
                                                lat: parseFloat(driver['Current Latitude']),
                                            }}
                                        />
                                    ))) : selectedIndex == 1 ? (unavaliabledrivers.map((driver, index) => (
                                        <Marker
                                            key={index}
                                            icon={{
                                                url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea',  // Path to your custom icon
                                                scaledSize: new window.google.maps.Size(50, 50), // Adjust width and height here
                                            }}
                                            position={{
                                                lng: parseFloat(driver['Current Longitude']),
                                                lat: parseFloat(driver['Current Latitude']),
                                            }}
                                        />
                                    ))) : (ridedoingdrivers.map((driver, index) => (
                                        <Marker
                                            key={index}
                                            icon={{
                                                url: 'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea',  // Path to your custom icon
                                                scaledSize: new window.google.maps.Size(50, 50), // Adjust width and height here
                                            }}
                                            position={{
                                                lng: parseFloat(driver['Current Longitude']),
                                                lat: parseFloat(driver['Current Latitude']),
                                            }}
                                        />
                                    )))}
                                </GoogleMap>
                            </LoadScript>

                        </div>
                        <div className="jjvnjvnfv" style={{ marginTop: '30px', width: '78vw', height: 'fit-content', marginBottom: '20px' }}>
                            <div className="jndjvnjf">
                                Trip Overview
                            </div>
                            <br />
                            <div className="kdjvfj">
                                <table style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
                                    <thead style={{ fontWeight: '300' }}>
                                        <tr>
                                            <th style={{ fontWeight: '400', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Cab Category</th>
                                            <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Booking Number</th>
                                            <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Pickup Point</th>
                                            <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Drop Location</th>
                                            <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Driver Name</th>
                                            <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Rider Name</th>
                                            {/* <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Booking Time</th> */}
                                            {/* <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Audio Recording</th> */}
                                            <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left' }}>Fare</th>
                                            <th style={{ fontWeight: '300', padding: '10px -10px', wordWrap: 'break-word', textAlign: 'left' }}>View Invoice</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {totalrides.map((ride, index) => (
                                            <tr key={index}>
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px' }}>{ride['Cab Category']}</td>
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px' }}>{ride['Booking ID']}</td>
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px' }}>{ride['Pickup Location']}</td>
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px' }}>{ride['Drop Location']}</td>
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px' }}><Link style={{ textDecoration: 'none' }}> {drivernames[index]}</Link></td>
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px' }}><Link style={{ textDecoration: 'none', color: 'black' }}> {ridernames[index]}</Link></td>
                                                {/* <td style={{ padding: '10px 20px', wordWrap: 'break-word' }}>{ride['Booking Time']}</td> */}
                                                {/* <td style={{ padding: '10px 20px', wordWrap: 'break-word' }}>{ride['Audio Recording']}</td> */}
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', fontWeight: '600' }}>₹{ride['Fare']}</td>
                                                <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px',cursor:'pointer' }}>
                                                    <div onClick={() => createReceipt(ride['Cab Category'],ride['Booking ID'],ride['Pickup Location'],ride['Drop Location'],ride['Fare'],drivernames[index],ridernames[index],ride['Travel Distance'],ride['Travel Time'])} style={{cursor:'pointer'}}>View</div>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>
                </div>
                <div className="njdnvv">
                    <div className="jnjnjvnf" >
                        <div className="jdjvjf">
                            <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/activeusers.png' alt="" height={"50px"} width={"50px"} />
                            <div className="hdffbj" style={{ fontSize: '18px', fontWeight: '700' }}>
                                User
                            </div>
                            <div className="hdffbj">
                                {riders.length}
                            </div>
                        </div>
                        <div className="jdjvjf" onClick={() => handleOptionClick(0)}>
                            <div className="jdjvjf">
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/driveravaliable.png' alt="" height={"50px"} width={"50px"} />
                                <div className="hdffbj" style={{ fontSize: '18px', fontWeight: '700', color: 'green' }}>
                                    Active<br />Driver
                                </div>
                                <div className="hdffbj" style={{ color: 'green' }}>
                                    {drivers.length}
                                </div>
                            </div>
                        </div>
                        <div className="jdjvjf" onClick={() => handleOptionClick(1)}>
                            <div className="jdjvjf">
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/driveravaliable.png' alt="" height={"50px"} width={"50px"} />
                                <div className="hdffbj" style={{ fontSize: '18px', fontWeight: '700', color: 'orange' }}>
                                    Inactive<br />Driver
                                </div>
                                <div className="hdffbj" style={{ color: 'orange' }}>
                                    {unavaliabledrivers.length}
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="jjvnjvnfv" style={{ height: '500px', marginTop: '20px' }}>
                        <div className="jndjvnjf">
                            Trip Statistics
                        </div>
                        <div className="jhdjfhv">
                            <div className="ddhhdb">
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/totalrides.png' alt="" height={"50px"} width={"50px"} />
                                <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '400' }}>
                                    Total Trips
                                </div>
                            </div>
                            <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '600', color: 'blue' }}>
                                {totalrides.length}
                            </div>
                        </div>
                        <div className="jhdjfhv">
                            <div className="ddhhdb">
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/totalrides.png' alt="" height={"50px"} width={"50px"} />
                                <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '400' }}>
                                    Completed Trips
                                </div>
                            </div>
                            <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '600', color: 'green' }}>
                                {completedrides.length}
                            </div>
                        </div>
                        <div className="jhdjfhv">
                            <div className="ddhhdb">
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/totalrides.png' alt="" height={"50px"} width={"50px"} />
                                <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '400' }}>
                                    Cancelled Trips
                                </div>
                            </div>
                            <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '600', color: 'red' }}>
                                {cancelledrides.length}
                            </div>
                        </div>
                        <div className="jhdjfhv">
                            <div className="ddhhdb">
                                <img src='https://g1uudlawy6t63z36.public.blob.vercel-storage.com/7630510-removebg-preview.png' alt="" height={"50px"} width={"50px"} />
                                <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '400' }}>
                                    Money Earned
                                </div>
                            </div>
                            <div className="dnfjjfj" style={{ fontSize: '15px', fontWeight: '600', color: 'orange' }}>
                                ₹30L
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
