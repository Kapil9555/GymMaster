// downloaded package require
import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import * as dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

dotenv.config();

const allowedOrigins = [
    "http://localhost:5173",
    process.env.CLIENT_URL,
].filter(Boolean);

// initialise downlaoded package
app.use(cors({
    origin: allowedOrigins,
    credentials: true,
}));
app.use(express.json());
app.use(bodyParser.urlencoded({extended:true}));

// Serve uploaded files statically
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

const PORT = process.env.PORT || 5000;
// user defined package
import connectDB from "./utils/connectDB.js";
// import User from "./models/User.js";
import authRoute from "./routes/authRoute.js";
import planRoute from "./routes/planCategoryRoute.js";
import subscriptionRoute from "./routes/subscriptionRoute.js";
import ContactRoute from "./routes/contactRoute.js";
import feedBackRoute from "./routes/feedBackRoute.js";
import memberRoute from "./routes/memberRoute.js";
import feeRoute from "./routes/feeRoute.js";

app.get("/", (req, res) =>{
res.send("server is running successfully");
});

app.use("/api/v1/auth", authRoute);
app.use("/api/v1/plan", planRoute);
app.use("/api/v1/subscription", subscriptionRoute);
app.use("/api/v1/contact", ContactRoute);
app.use("/api/v1/feedback", feedBackRoute);
app.use("/api/v1/member", memberRoute);
app.use("/api/v1/fee", feeRoute);


const startServer = async () => {
    try{
        connectDB(process.env.MONGODB_URI);
        app.listen(PORT, () => {
         console.log(`server is running on port ${PORT}`);
        });        
    }

    catch(err){
        console.log(err || "some error in starting server");
    }
}

startServer();








