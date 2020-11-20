import { hello } from "./bar.js";

var hungry = "hippo";
export function awesome() {
  console.log(
    hello( hungry ).toUpperCase()
  );
}

export default {
  awesome
}
