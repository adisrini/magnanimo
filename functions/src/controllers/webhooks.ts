import { Controller } from "../model/types";

export const webhooksController: Controller = {
  path: "/webhooks",
  register: (router, stripe, firestore) => {
    router.get("/ping", (req, res) => {
      res.send("pong");
    });
  }
};
