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
        setDirections(null);

        if (selectedPickupLocation && selectedDropLocation) {
            const directionsService = new window.google.maps.DirectionsService();

            const request = {
                origin: selectedPickupLocation,
                destination: selectedDropLocation,
                travelMode: window.google.maps.TravelMode.DRIVING,
            };

            directionsService.route(request, (result, status) => {
                if (status === window.google.maps.DirectionsStatus.OK) {
                    console.log("Directions response:", result);
                    setDirections(result);
                    const distance = result.routes[0].legs[0].distance.text;
                    const duration = result.routes[0].legs[0].duration.text;

                    console.log(`Distance: ${distance}, Duration: ${duration}`);
                    setDistanceAndTime({ distance, duration });

                    // Adjust the map bounds to fit the route
                    if (mapRef.current) {
                        const bounds = new window.google.maps.LatLngBounds();
                        result.routes[0].overview_path.forEach((latLng) => {
                            bounds.extend(latLng);
                        });
                        mapRef.current.fitBounds(bounds);
                    }
                } else {
                    console.error("Directions request failed:", status);
                }
            });
        }
    }, [selectedPickupLocation, selectedDropLocation]);

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
    const [pickuplocation, setpickuplocation] = useState('');
    const [droplocation, setdroplocation] = useState('');
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
    const [fare,setfare]=useState(0);
    useEffect(() => {
        const fetchdata = async() => {
            const DriverID='';
            const docRef=doc(db,'Booking Details',RideID);
            const docSnap=await getDoc(docRef);
            if(docSnap.exists()){
                setpickuplocation(docSnap.data()['Pickup Location']);
                setpickuplong(docSnap.data()['Pick Longitude']);
                setpickuplat(docSnap.data()['Pickup Latitude']);
                setdroplocation(docSnap.data()['Drop Location']);
                setdroplong(docSnap.data()['Drop Longitude']);
                setdroplat(docSnap.data()['Drop Latitude']);
                DriverID=docSnap.data()['Driver ID'];
                setDriver(docSnap.data()['Driver ID']);
                setrideveried(docSnap.data()['Ride Verified']);
                setOTP(docSnap.data()['Ride OTP']);
                setfare(docSnap.data()['Fare']);
            }
        };
        fetchdata();
    }, [user])
    const mapCenter = selectedDropLocation
        ? {
            lat: (selectedPickupLocation.lat + selectedDropLocation.lat) / 2,
            lng: (selectedPickupLocation.lng + selectedDropLocation.lng) / 2,
        }
        : selectedPickupLocation || defaultLatLng;
    return (
        <div className='webbody'>
            <div className="ejhfjhfd">
            <div className="jnjndjvnjdv">

            </div>
                <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM" libraries={['places']}>
                    <GoogleMap
                        mapContainerStyle={mapContainerStyle}
                        center={mapCenter}
                        zoom={17}
                        options={mapOptions}
                        onLoad={(map) => (mapRef.current = map)} // Store map instance in the ref
                    >
                        {selectedPickupLocation && <Marker position={selectedPickupLocation} />}
                        {selectedDropLocation && <Marker position={selectedDropLocation} />}

                        {/* Render markers for each nearby driver */}
                        {markers.map((driver) => (
                            <Marker
                                key={driver.id}
                                position={driver.position}
                                icon={{
                                    url: "https://d1a3f4spazzrp4.cloudfront.net/car-types/map70px/map-blue-uberx.png",
                                    scaledSize: new window.google.maps.Size(40, 40), // Adjust marker size
                                }}
                            />
                        ))}

                        {directions && directions.routes[0].overview_path && (
                            <Polyline
                                path={directions.routes[0].overview_path}
                                options={{
                                    strokeColor: 'black',
                                    strokeOpacity: 1,
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
