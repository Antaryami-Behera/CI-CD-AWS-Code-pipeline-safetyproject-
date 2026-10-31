import "dotenv/config";
import express from "express";

const app = express();
const PORT = Number(process.env.PORT) || 4000;

app.get("/api/app/health", (_req, res) => {
  res.status(200).json({
    status: "ok",
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`MySafety health server running on port ${PORT}`);
});
