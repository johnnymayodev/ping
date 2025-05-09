import { configDotenv } from "dotenv";
import { Hono } from "hono";

configDotenv();

const PORT: number = parseInt(process.env.PORT || "3000", 10);
const PATH: string = "/ping";

const app = new Hono();

app.get(PATH, (c) => {
  return c.text("pong", 200);
});

app.get(PATH + "/health", (c) => {
  return c.json(
    {
      message: "I'm doing great! Thank you for asking!",
      uptime: process.uptime().toFixed(4),
    },
    200,
  );
});

export default {
  port: PORT,
  fetch: app.fetch,
};
