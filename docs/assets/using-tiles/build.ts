import { colorful } from "@versatiles/style";
import { writeFileSync } from "node:fs";

const style = colorful({
    baseUrl: "https://example.com",
    fonts: { regular: "Noto Sans", bold: "Noto Sans Bold" },
    sprite: [{ id: 'basics', url: "/sprites/basics/sprites" }],
    tiles: ["https://vector.openstreetmap.org/shortbread_v1/{z}/{x}/{y}.mvt"]
});

// We're using web fonts so we don't need glyphs
delete style.glyphs;
writeFileSync("release/style.json", JSON.stringify(style));
