import React, { useEffect, useRef, useState } from 'react';
import { onAuthStateChanged, getAuth } from "firebase/auth";
import { arrayRemove, arrayUnion, collection, deleteField, doc, FieldValue, getDoc, getFirestore, onSnapshot, serverTimestamp, setDoc, updateDoc } from "firebase/firestore";
import { initializeApp } from "firebase/app";
import { GoogleMap, LoadScript, Marker, Polyline } from '@react-google-maps/api';
import { Link, useParams } from 'react-router-dom';

const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:0f8c6be4228dba901ea368",
    measurementId: "G-ZFRR1BZQFV",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
const defaultLatLng = { lat: 22.5660201, lng: 88.3630783 };

export default function Activeride_laptop() {
    const mapRef = useRef(null);
    const cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi'];
    const cabcategorydescription = [
        'Highly Discounted fare',
        'Spacious sedans, top drivers',
        'Spacious SUVs',
        ''];
    const [markers, setMarkers] = useState([]);
    const carcategoryimages = [
        'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/Hatchback.png',
        'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/v1.1/UberX_v1.png',
        'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/package_UberXL_new_2022.png',
        'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png'
    ];
    const [user, setUser] = useState('');
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [userName, setUserName] = useState(null);
    const [userPfp, setUserPfp] = useState(null);

    const [pickupLocation, setPickupLocation] = useState('');
    const [dropLocation, setDropLocation] = useState('');
    const [pickupSuggestions, setPickupSuggestions] = useState([]);
    const [dropSuggestions, setDropSuggestions] = useState([]);
    const [selectedPickupLocation, setSelectedPickupLocation] = useState(defaultLatLng);
    const [selectedDropLocation, setSelectedDropLocation] = useState(null);
    const [mapContainerStyle, setMapContainerStyle] = useState({
        width: '100vw',
        height: '100vh',
    });
    const [directions, setDirections] = useState(null);
    const [distanceAndTime, setDistanceAndTime] = useState({ distance: '', duration: '' });

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
            if (currentUser) {
                setUser(currentUser.uid);
            } else {
                // window.location.replace('/');
            }
        });

        return () => unsubscribe();
    }, []);
    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };
    const [pickuplocations, setpickuplocations] = useState('');
    const [droplocations, setdroplocations] = useState('');
    const [pickuplong, setpickuplong] = useState(0);
    const [droplong, setdroplong] = useState(0);
    const [driver, setDriver] = useState('');
    const [pickuplat, setpickuplat] = useState(0);
    const [droplat, setdroplat] = useState(0);
    const [carcategory, setCarcategory] = useState('');
    const [carmodel, setCarmodel] = useState('');
    const [carregnumber, setcarregnumber] = useState('');
    const [OTP, setOTP] = useState(0);
    const [drivername, setdrivername] = useState('');
    const [driverphone, setdriverphone] = useState('');
    const [rideverified, setrideveried] = useState(false);
    const [carimage, setcarimage] = useState('');
    const { RideID } = useParams();
    const [fare, setfare] = useState(0);
    const [mapCenter, setMapCenter] = useState(null);
    const [driverlat, setdriverlat] = useState(0);
    const [driverlong, setdriverlong] = useState(0);
    const [dataFetched, setDataFetched] = useState(false); // Track if data is fetched
    const [isridecancelled,setridecancelled]=useState(false);
    const [ridecompleted,setridecompleted]=useState(false);
    const [rideaccepted,setrideaccepted]=useState(false);
    const [paymentid, setpaymentid] = useState('');
    const handleRefund = async () => {
        // Retrieve Payment ID and Fare from localStorage
        const paymentID = localStorage.getItem('Payment ID');
      
        // Check if paymentID and fare are available
        if (!paymentID || !fare) {
          console.error("Missing Payment ID or Fare from localStorage");
          return;
        }
      
        const refundData = {
          paymentId: paymentID,  // paymentId should match what the backend expects
          amount: parseInt(fare, 10),  // Convert fare to integer (in paise)
        };
      
        try {
          const response = await fetch('http://localhost:4000/refund', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(refundData),
          });
      
          // Parse the response as JSON
          const data = await response.json();
      
          if (response.ok) {
            // Refund successful, show an alert
            // alert('Refund successful!');
            console.log('Refund successful:', data);
            await cancelride();
          } else {
            // Refund failed, log error message
            // alert('Refund failed: ' + data.error);
            console.error('Refund failed:', data.error);
          }
        } catch (error) {
          // Handle network or other errors
          console.error('Error:', error);
        //   alert('Error occurred during refund.');
        }
      };
      
    useEffect(() => {
        let unsubscribe = null;  // Declare unsubscribe variable here

        const fetchData = async () => {
            try {
                // Fetch Booking Details
                const docRef = doc(db, 'Ride Details', RideID);
                const docSnap = await getDoc(docRef);

                if (docSnap.exists()) {
                    setpickuplocations(docSnap.data()['Pickup Location']);
                    setpickuplong(docSnap.data()['Pick Longitude']);
                    setpickuplat(docSnap.data()['Pickup Latitude']);
                    const pickupLocation = docSnap.data()['Pickup Location'];
                    const pickupLongitude = docSnap.data()['Pick Longitude'];
                    const pickupLatitude = docSnap.data()['Pickup Latitude'];
                    const dropLocation = docSnap.data()['Drop Location'];
                    setdroplocations(docSnap.data()['Drop Location']);
                    setdroplong(docSnap.data()['Drop Longitude']);
                    setdroplat(docSnap.data()['Drop Latitude']);
                    setridecompleted(docSnap.data()['Ride Completed']);
                    const DriverID = docSnap.data()['Driver ID'];
                    setDriver(DriverID);
                    setrideveried(docSnap.data()['Ride Verified']);
                    setOTP(docSnap.data()['Ride OTP']);
                    setfare(docSnap.data()['Fare']);
                    setMapCenter({ lat: pickupLatitude, lng: pickupLongitude });
                    document.title = `Journey To ${docSnap.data()['Drop Location']} | VistaRide`;

                    // Add real-time listener for Ride Verified field
                    unsubscribe = onSnapshot(docRef, (docSnapshot) => {
                        const data = docSnapshot.data();
                        if (data && data['Ride Verified'] !== undefined) {
                            setrideaccepted(data['Ride Accepted']);
                            setridecompleted(data['Ride Completed']);
                            setrideveried(data['Ride Verified']);
                            if(data['Ride Accepted']==false){
                                window.location.replace('/go/home');
                            }
                            // console.log('Ride Verified status changed:', data['Ride Completed']);
                        }
                    });

                    // Fetch Driver Details if Driver ID exists
                    if (DriverID) {
                        const DriverRef = doc(db, 'VistaRide Driver Details', DriverID);
                        await updateDoc(DriverRef,{
                            'Ride Requested':deleteField()
                        })
                        const driverSnap = await getDoc(DriverRef);

                        if (driverSnap.exists()) {
                            setdrivername(driverSnap.data()['Name']);
                            setdriverphone(driverSnap.data()['Contact Number']);
                            setcarimage(driverSnap.data()['Car Photo']);
                            setcarregnumber(driverSnap.data()['Car Number Plate']);
                            setCarmodel(driverSnap.data()['Car Name']);
                            setCarcategory(driverSnap.data()['Car Category']);
                            setdriverlat(parseFloat(driverSnap.data()['Current Latitude']));
                            setdriverlong(parseFloat(driverSnap.data()['Current Longitude']));
                            console.log(driverSnap.data()['Driver Latitude']);
                        } else {
                            console.error('Driver details not found for ID:', DriverID);
                        }
                    } else {
                        console.error('Invalid Driver ID:', DriverID);
                    }
                } else {
                    console.error('Booking details not found for RideID:', RideID);
                }
            } catch (error) {
                console.error('Error fetching data:', error);
            } finally {
                setLoading(false);
                setDataFetched(true);
            }
        };

        fetchData();

        // Cleanup function to unsubscribe from the listener
        return () => {
            if (unsubscribe) {
                unsubscribe(); // Unsubscribe from the snapshot listener
            }
        };
    }, [user, db, RideID]);
        const cancelride=async()=>{
            try{
                
                const docRef = doc(db, 'Ride Details', RideID);
                await updateDoc(docRef, {
                    'Ride Accepted': false,
                    'Ride Cancelled':true,
                    'Cancellation Time':new Date(),
                });
                // console.log('Ride cancelled:', updateDoc);
                const driverRef=doc(db,'VistaRide Driver Details',driver);
                await updateDoc(driverRef, {
                    'Ride Doing':deleteField(),
                    'Driver Avaliable':true
                });
                
                setridecancelled(true);
                window.location.replace('/go/home')
            }catch(error){
                console.error('Error cancelling ride:', error);
            }
        };
        
    // Trigger this effect when 'user' or 'db' changes
    const [directionsPath, setDirectionsPath] = useState([]);
    useEffect(() => {
        if (pickuplat && pickuplong && driverlat && driverlong && droplat && droplong) {
            const directionsService = new window.google.maps.DirectionsService();

            // Determine the origin and destination based on the `rideverified` status
            const request = {
                origin: {
                    lat: rideverified ? driverlat : pickuplat,
                    lng: rideverified ? driverlong : pickuplong
                },
                destination: {
                    lat: rideverified ? droplat : driverlat,
                    lng: rideverified ? droplong : driverlong
                },
                travelMode: window.google.maps.TravelMode.DRIVING,
            };

            // Request directions
            directionsService.route(request, (result, status) => {
                if (status === window.google.maps.DirectionsStatus.OK) {
                    const path = result.routes[0].overview_path;
                    setDirectionsPath(path); // Set the road-following polyline

                    const distance = result.routes[0].legs[0].distance.text;
                    const duration = result.routes[0].legs[0].duration.text;
                    setDistanceAndTime({ distance, duration });

                    // Set the map center based on the updated origin (either the driver or the pickup)
                    setMapCenter({
                        lat: rideverified ? driverlat : pickuplat,
                        lng: rideverified ? driverlong : pickuplong
                    });
                } else {
                    console.error("Directions request failed due to " + status);
                }
            });
        }
    }, [pickuplat, pickuplong, driverlat, driverlong, droplat, droplong, rideverified]);

    return (
        <div className='webbody'>
            <div className="ejhfjhfd">
                <div className="jnjndjvnjdv">
                    <div className="mdmndv">
                        <div className="knfvnfv">
                            <img src={carimage} alt="" width={'80%'} height={'80%'} />
                        </div>
                        
                        <div className="jdnvjndvjn">
                        <div className="dnjndjv" style={{color:'black',fontWeight:'600'}}>
                                {rideverified?ridecompleted?(`Please pay ₹${fare} to the driver`):(`Ride verified. Have a safe journey.`):(`Please share the OTP ${OTP} to start trip.`)}
                            </div><br />
                            {carregnumber}
                            <div className="dnjndjv">
                                <div>
                                    {carmodel}
                                </div>
                                <div>
                                    {drivername}
                                </div>
                            </div>
                            <div className="dnjndjv" style={{ color: 'black', marginTop: '50px' }}>
                                <div>
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" data-baseweb="icon"><title>search</title><path fill-rule="evenodd" clip-rule="evenodd" d="M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Zm5-2a5 5 0 1 1-10 0 5 5 0 0 1 10 0Z" fill="currentColor"></path></svg>
                                </div>
                                <div>
                                    {pickuplocations}
                                </div>
                            </div>
                            <div className="dnjndjv" style={{ color: 'black', marginTop: '50px' }}>
                                <div>
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" data-baseweb="icon"><title>search</title><path fill-rule="evenodd" clip-rule="evenodd" d="M14 10h-4v4h4v-4ZM7 7v10h10V7H7Z" fill="currentColor"></path></svg>
                                </div>
                                <div>
                                    {droplocations}
                                </div>
                            </div>
                            {user!=''? rideverified?<></>:(<div className="rnnfbnfmbn" onClick={handleRefund}>
                                <div className="mnbngb">
                                    Cancel Ride
                                </div>
                            </div>):<></>}
                        </div>
                    </div>
                    
                </div>
                
                {/* maps */}
                <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM">
                    <GoogleMap
                        mapContainerStyle={{ height: '100vh', width: '100vw' }}
                        center={mapCenter}
                        zoom={14}
                        options={mapOptions}
                    >
                        {/* Pickup Location Marker */}
                        {pickuplat && pickuplong && (
                            <Marker position={{ lat: rideverified ? droplat : pickuplat, lng: rideverified ? droplong : pickuplong }} label="" icon={{
                                url: `https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fpngimg.com%20-%20pin_PNG27.png?alt=media&token=a7926167-44dd-4938-b74f-030f0487e5b4`,
                                scaledSize: new window.google.maps.Size(50, 50), // Adjust marker size
                            }} />
                        )}
                        {/* Driver Location Marker */}
                        {driverlat && driverlong && (
                            <Marker position={{ lat: driverlat, lng: driverlong }} label="" icon={{
                                url: `${carimage}`,
                                scaledSize: new window.google.maps.Size(50, 50), // Adjust marker size
                            }} />
                        )}

                        {/* Polyline based on Directions */}
                        {directionsPath.length > 0 && (
                            <Polyline
                                path={directionsPath}
                                options={{
                                    strokeColor: 'black',
                                    strokeOpacity: 0.7,
                                    strokeWeight: 4,
                                }}
                            />
                        )}
                    </GoogleMap>
                </LoadScript>
            </div>

        </div>
    )
}
