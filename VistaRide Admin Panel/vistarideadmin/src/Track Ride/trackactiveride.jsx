import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker, DirectionsRenderer } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, doc, onSnapshot } from 'firebase/firestore';
import { useParams } from 'react-router-dom';

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

export default function Trackactiveride() {
    // Get the rideID from the URL parameters
    const { rideID } = useParams();

    const [rideDetails, setRideDetails] = useState(null); // To store the ride details
    const [loading, setLoading] = useState(true); // To manage loading state
    const [error, setError] = useState(null); // To handle errors
    const [directions, setDirections] = useState(null); // Store directions result

    // Setup the Firestore real-time listener
    useEffect(() => {
        console.log('Ride ID', rideID);
        // Create a reference to the ride document
        const rideRef = doc(db, 'Ride Details', rideID);

        // Real-time listener for the ride document
        const unsubscribe = onSnapshot(rideRef, (docSnap) => {
            if (docSnap.exists()) {
                setRideDetails(docSnap.data()); // Update state with the new ride data
                setLoading(false); // Set loading to false when data is fetched
            } else {
                setError('Ride not found');
                setLoading(false);
            }
        }, (err) => {
            setError('Error fetching ride details');
            setLoading(false);
        });

        // Cleanup listener on unmount or rideID change
        return () => unsubscribe();
    }, [rideID]);

    // Extract pickup and drop-off coordinates
    const pickupLatitude = rideDetails?.["Pickup Latitude"];
    const pickupLongitude = rideDetails?.["Pick Longitude"];
    const dropLatitude = rideDetails?.["Drop Latitude"];
    const dropLongitude = rideDetails?.["Drop Longitude"];

    // Default center of the map (if no location is found)
    const defaultCenter = {
        lat: 37.7749, // Default latitude (San Francisco)
        lng: -122.4194, // Default longitude (San Francisco)
    };

    // Map container style
    const mapContainerStyle = {
        width: '100%',
        height: '100%',
    };

    // Effect to calculate route when locations are available
    useEffect(() => {
        if (pickupLatitude && pickupLongitude && dropLatitude && dropLongitude && window.google) {
            const directionsService = new window.google.maps.DirectionsService();

            // Request the route from pickup to drop-off
            directionsService.route(
                {
                    origin: { lat: pickupLatitude, lng: pickupLongitude },
                    destination: { lat: dropLatitude, lng: dropLongitude },
                    travelMode: window.google.maps.TravelMode.DRIVING,
                },
                (result, status) => {
                    if (status === window.google.maps.DirectionsStatus.OK) {
                        setDirections(result); // Store the route result
                    } else {
                        setError('Error fetching directions');
                    }
                }
            );
        }
    }, [pickupLatitude, pickupLongitude, dropLatitude, dropLongitude]);

    // Custom icon URLs (use your custom images here)
    const pickupIcon = {
        url: "https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fpngtree-red-car-top-view-icon-png-image_3745904-removebg-preview.png?alt=media&token=ec094a1a-9864-4a06-9b44-529d04ed2a29", // Replace with actual image URL
        scaledSize: new window.google.maps.Size(50, 50), // Set custom size to 50x50
    };
    const dropIcon = {
        url: "https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fpngimg.com%20-%20pin_PNG27.png?alt=media&token=a7926167-44dd-4938-b74f-030f0487e5b4", // Replace with actual image URL
        scaledSize: new window.google.maps.Size(50, 50), // Set custom size to 50x50
    };
    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };
    return (
        <div className="webbody">
            <LoadScript
                googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM"
                libraries={['places']}
            >
                <GoogleMap
                    mapContainerStyle={mapContainerStyle}
                    center={{ lat: pickupLatitude || defaultCenter.lat, lng: pickupLongitude || defaultCenter.lng }}
                    zoom={13}
                    options={mapOptions}
                >
                    {/* Markers for pickup and drop-off locations with custom icons */}
                    {pickupLatitude && pickupLongitude && (
                        <Marker
                            position={{ lat: pickupLatitude, lng: pickupLongitude }}
                            icon={pickupIcon} // Use custom pickup icon
                        />
                    )}
                    {dropLatitude && dropLongitude && (
                        <Marker
                            position={{ lat: dropLatitude, lng: dropLongitude }}
                            icon={dropIcon} // Use custom drop icon
                        />
                    )}

                    {/* DirectionsRenderer to show the route with black polyline */}
                    {directions && (
                        <DirectionsRenderer
                            directions={directions}
                            options={{
                                polylineOptions: {
                                    strokeColor: 'black', // Set polyline color to black
                                    strokeOpacity: 1.0,
                                    strokeWeight: 4,
                                },
                            }}
                        />
                    )}
                </GoogleMap>
            </LoadScript>
        </div>
    );
}
