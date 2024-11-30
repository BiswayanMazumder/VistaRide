import logo from './logo.svg';
import './App.css';
import {
  BrowserRouter,
  Routes,
  Route
} from 'react-router-dom';
import LandingPage from './Opening Page/LandingPage';
import Cabbookingpage from './Opening Page/HomePage/cabbookingpage';
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
      </Routes>
      <Routes>
        <Route path="/go/home" element={<Cabbookingpage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
