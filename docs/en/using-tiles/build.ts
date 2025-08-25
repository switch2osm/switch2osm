import { colorful } from "@versatiles/style";
import { writeFileSync } from "node:fs";

const style = colorful({
    baseUrl: "https://example.com",
    glyphs: "/fonts/{fontstack}/{range}.pbf",
    sprite: "/sprites/basics/sprites",
    tiles: ["https://vector.openstreetmap.org/shortbread_v1/{z}/{x}/{y}.mvt"]
});
writeFileSync("release/style.json", JSON.stringify(style));
