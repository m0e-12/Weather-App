const dotenv = require('dotenv');
dotenv.config();

const express = require('express');
const mysql = require('mysql2');
const axios = require('axios');
const bcrypt = require('bcrypt');



const API_URL = process.env.API_URL || 'https://api.openweathermap.org/data/2.5/weather';
const API_KEY = process.env.API_KEY || 'your-default-api-key';

const app = express();
const cors = require('cors');
app.use(cors());


const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
});

db.connect((err) => {
    if (err) {
        console.error('Failed to connect to MySQL:', err.message);
    } else {
        console.log('Connected to MySQL');
    }
});



app.post('/register', async (req, res) => {
    const { username, password } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        db.query(
            'INSERT INTO users (username, password) VALUES (?, ?)',
            [username, hashedPassword],
            (err, result) => {
                if (err) {
                    console.error('Error registering user:', err.message);
                    return res.status(500).json({ error: 'Database error' });
                }
                res.status(201).json({ message: 'User registered successfully' });
            }
        );
    } catch (error) {
        console.error('Error hashing password:', error.message);
        res.status(500).json({ error: 'Server error' });
    }
});

app.post('/weather/save', (req, res) => {
    const { userId, city, temperature, description, humidity, wind_speed } = req.body;

    db.query(
        'INSERT INTO weather_data (user_id, city, temperature, description, humidity, wind_speed) VALUES (?, ?, ?, ?, ?, ?)',
        [userId, city, temperature, description, humidity, wind_speed],
        (err, result) => {
            if (err) {
                console.error('Error saving weather data:', err.message);
                return res.status(500).json({ error: 'Database error' });
            }
            res.status(201).json({ message: 'Weather data saved successfully' });
        }
    );
});

app.get('/weather/:userId', (req, res) => {
    const userId = req.params.userId;

    db.query(
        'SELECT * FROM weather_data WHERE user_id = ? ORDER BY created_at DESC',
        [userId],
        (err, results) => {
            if (err) {
                console.error('Error fetching weather data:', err.message);
                return res.status(500).json({ error: 'Database error' });
            }
            res.json(results);
        }
    );
});



app.get('/', (req, res) => {
    res.send('Welcome to the Weather App API');
});

app.get('/weather', async (req, res) => {
    const city = req.query.city;
    console.log(`Fetching weather data for city: ${req.query.city}`);
    console.log('Using API URL:', API_URL);
    console.log('Using API Key:', API_KEY);

    if (!city) {
        return res.status(400).json({ error: 'City is required' });
    }

    try {
        const response = await axios.get(API_URL, {
            params: {
                q: req.query.city,
                appid: API_KEY,
                units: 'metric',
            },
        });

        console.log(`Weather data retrieved for city: ${city}`);
        const weatherData = {
            city: response.data.name,
            temperature: response.data.main.temp,
            description: response.data.weather[0].description,
            humidity: response.data.main.humidity,
            wind_speed: response.data.wind.speed,
        };

        res.json(weatherData);
    } catch (error) {
        console.error(`Failed to fetch weather data for city: ${city}`, error.message);
        res.status(500).json({ error: 'Unable to retrieve weather data at this time. Please try again later.' });
    }
});

const PORT = process.env.PORT || 5050;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));




// const express = require('express');
// const mysql = require('mysql2');
// const dotenv = require('dotenv');
// dotenv.config();
// const axios = require('axios');
// const API_URL = process.env.API_URL || 'https://api.openweathermap.org/data/2.5/weather';
// const API_KEY = process.env.API_KEY || 'your-default-api-key';



// const app = express();

// const db = mysql.createConnection({
//     host: process.env.DB_HOST,
//     user: process.env.DB_USER,
//     password: process.env.DB_PASS,
//     database: process.env.DB_NAME
// });
// db.connect((err) => {
//     if (err) throw err;
//     console.log('Connected to MySQL');

// });


//     app.get('/', (req, res) => {
//         res.send('Welcome to the Weather App API');
    
// });

// app.get('/weather', async (req, res) => {
//     const city = req.query.city; 

//     if (!city) {
//         return res.status(400).json({ error: 'City is required' });
//     }
    
//     try { 
//         const response = await axios.get(process.env.API_URL, { 
//             params: { 
//                 q: city, 
//                 appid: process.env.API_KEY, 
//                 units: 'metric' 
//             } 
//         }); 
    
//         const weatherData = { 
//             city: response.data.name, 
//             temperature: response.data.main.temp, 
//             description: response.data.weather[0].description, 
//             humidity: response.data.main.humidity, 
//             wind_speed: response.data.wind.speed 
//         }; 
    
//         res.json(weatherData);
//     } catch (error) {
//         console.error(`Failed to fetch weather data for city: ${city}`, error.message);
//         res.status(500).json({ error: 'Unable to retrieve weather data at this time. Please try again later.' });
//     }
    
// });

// const PORT = process.env.PORT || 5050;
// app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
