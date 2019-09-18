import { Controller } from "../model/types";

export const chargesController: Controller = {
  path: "/charges",
  register: (router, stripe, firestore) => {
    router.get("/test", (req, res) => {
      res.send({ hello: "charges" });
    });
  }
};
