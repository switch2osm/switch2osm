import { colorful } from "@versatiles/style";
import { writeFileSync } from "node:fs";

const style = colorful({
    baseUrl: "http://localhost:8080",
    fonts: { regular: "Noto Sans", bold: "Noto Sans Bold" },
    sprite: [{ id: "basics", url: "/sprites/basics/sprites" }],
    tiles: ["http://localhost:3000/shortbread/{z}/{x}/{y}"]
});

// The example uses web fonts, so the style does not need a glyph server.
delete style.glyphs;
writeFileSync("release/style.json", JSON.stringify(style, null, 2));
