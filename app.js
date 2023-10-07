// Import required modules
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser'); // Import body-parser
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken'); // Import jsonwebtoken library
const cors = require('cors'); // Import the cors middleware



// Create an Express app
const app = express();
const path = require('path');

// Use the cors middleware
app.use(cors({
//    origin: 'http://127.0.0.1:3000' I'm having some trouble with CORS so let's try disabling this line
}));

app.use('/protected', authenticateToken, (req, res) => {
  res.json({ message: 'You have accessed a protected route!' });
});

function authenticateToken(req, res, next) {
  // Get the token from the request headers
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer <Token>

  if (!token) return res.status(401).json({ message: 'Token not provided' });

  // Verify the token
  jwt.verify(token, 'your-secret-key', (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid Token' });
    req.user = user; // Store user info in the request object
    next(); // Move to the next middleware or route handler
  });
}

app.use(express.static(path.join(__dirname, '/')));

app.use(bodyParser.json()); // Parse JSON requests

// Set up MongoDB connection
mongoose.connect('mongodb+srv://talmagesharp321:Ihateps4@nebulacluster.9d57wlp.mongodb.net/?retryWrites=true&w=majority', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'MongoDB connection error:'));
db.once('open', () => {
  console.log('Connected to MongoDB');
});

const User = mongoose.model('User', {
 username: String,
 password: String,
 email: String,
// profilePicture: Image,
// email: String,

});

const Squat = mongoose.model('Squat', {
 name: String,
 location: String,
 likes: Number,
 image: String,
 /*creator: {
    type: Schema.Types.ObjectId,
    ref: 'User'
 }*/
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '/', 'build/web/index.html'));
});

app.post('/new_squat', async(req, res) => {
 const { name, location, image, likes } = req.body;
 const newSquat = new Squat({ name, location, image, likes});
   await newSquat.save();

   res.status(201).json({ message: 'Squat created successfully' });

});

app.get('/user-data', authenticateToken, async (req, res) => {
    try {
    const userId = req.user.userId;
    const user = await User.findById(userId);

    if(!user){
        return res.status(404).json({ message: 'User not found'});
    }

    return res.json({email: user.email, username: user.username });
    } catch (error) {
        return res.status(500).json({ message: 'server error'});
    }
});

app.get('/check_username/:username', async (req, res) => {
  const { username } = req.params;
  const user = await db.collection('users').findOne({ username });
  if (user) {
    res.status(409).send('taken');
  } else {
    res.status(200).send('available');

  }
});

app.get('/squats', authenticateToken, async (req, res) => {
  try {
//  log('Looking for squats in the database');
    const squats = await Squat.find(); // Fetch all squats from the database
    res.json(squats); // Return squats as JSON response
  } catch (error) {
    res.status(500).json({ error: 'Error fetching squats' });
  }
});

app.post('/register', async (req, res) => {
//  console.log('attempting to post the username and password');
//  console.log(req);
  const { username, email, password,  } = req.body;

  // Hash the password before saving it
  const hashedPassword = await bcrypt.hash(password, 10);

  // Create a new user record in the database

  const newUser = new User({ username, email, password: hashedPassword });
  await newUser.save();

  res.status(201).json({ message: 'User registered successfully' });
});

app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  // Fetch user data from the database based on the provided username
  const user = await User.findOne({ username });

  if (!user) {
    return res.status(401).json({ message: 'No User Found' });
  }

  // Compare the provided password with the hashed password in the database
  const passwordMatch = await bcrypt.compare(password, user.password);

  if (!passwordMatch) {
    return res.status(401).json({ message: 'Invalid password' });
  }

  // Generate a JWT token
  const token = jwt.sign({ userId: user._id }, 'your-secret-key', {expiresIn: '1hr'});

  res.cookie('jwt', token, { /*httpOnly: true, secure: false,*/ maxAge: 3600000 }); // maxAge is set to 1 hour here
  res.status(200).json({ message: 'Login successful' });

//  console.log('login successful!');
});
// Set up your routes and middleware
// ...

// Start the Express server
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}`);
});

/* Your Problems:
1. You have no routes for your login and signup in your DB
2. You need to have the login/signup pages use push commands to login
3. You need to use user authentication.
4. you should probably learn how to actually do it and not just have ChatGPT code it all for you hahahah
*/
