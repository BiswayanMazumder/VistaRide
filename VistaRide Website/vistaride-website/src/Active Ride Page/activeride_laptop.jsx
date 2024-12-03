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
                window.location.replace('/');
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
    useEffect(() => {
        const fetchdata = async () => {
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
                    const DriverID = docSnap.data()['Driver ID'];
                    setDriver(DriverID);
                    setrideveried(docSnap.data()['Ride Verified']);
                    setOTP(docSnap.data()['Ride OTP']);
                    setfare(docSnap.data()['Fare']);
                    setMapCenter({ lat: pickupLatitude, lng: pickupLongitude });
                    document.title = `Journey To ${docSnap.data()['Drop Location']} | VistaRide`;
                    // console.log('Pickup Latitude: ' + docSnap.data()[')
                    // Fetch Driver Details only if DriverID is valid
                    if (DriverID) {
                        const DriverRef = doc(db, 'VistaRide Driver Details', DriverID);
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

        fetchdata();
    }, [user, db]); // Trigger this effect when 'user' or 'db' changes
    const [directionsPath, setDirectionsPath] = useState([]);
    useEffect(() => {
        if (pickuplat && pickuplong && driverlat && driverlong) {
            const directionsService = new window.google.maps.DirectionsService();
            const request = {
                origin: { lat: pickuplat, lng: pickuplong },
                destination: { lat: driverlat, lng: driverlong },
                travelMode: window.google.maps.TravelMode.DRIVING,
            };

            directionsService.route(request, (result, status) => {
                if (status === window.google.maps.DirectionsStatus.OK) {
                    const path = result.routes[0].overview_path;
                    setDirectionsPath(path); // Set the road-following polyline
                    const distance = result.routes[0].legs[0].distance.text;
                    const duration = result.routes[0].legs[0].duration.text;
                    setDistanceAndTime({ distance, duration });
                    setMapCenter({ lat: pickuplat, lng: pickuplong });
                } else {
                    console.error("Directions request failed due to " + status);
                }
            });
        }
    }, [pickuplat, pickuplong, driverlat, driverlong]);
    return (
        <div className='webbody'>
            <div className="ejhfjhfd">
                <div className="jnjndjvnjdv">
                    <div className="mdmndv">
                        <div className="knfvnfv">
                            <img src={carimage} alt="" width={'80%'} height={'80%'} />
                        </div>
                        <div className="jdnvjndvjn">
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
                        </div>
                    </div>
                </div>
                {/* maps */}
                <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM">
                    <GoogleMap
                        mapContainerStyle={{ height: '100vh', width: '100vw' }}
                        center={mapCenter}
                        zoom={14}
                    >
                        {/* Pickup Location Marker */}
                        {pickuplat && pickuplong && (
                            <Marker position={{ lat: pickuplat, lng: pickuplong }} label="" />
                        )}
                        {/* Driver Location Marker */}
                        {driverlat && driverlong && (
                            <Marker position={{ lat: driverlat, lng: driverlong }} label="" />
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
