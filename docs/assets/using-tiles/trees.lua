node_keys = { "natural=tree" }
way_keys = { "natural=tree_row", "natural=wood", "landuse=forest" }


function node_function(node)
    -- natural=tree on a node is a tree point
    if Find("natural") == "tree" then
        Layer("tree_points", false)
        Attribute("name", Find("name"))
        Attribute("leaf_type", Find("leaf_type"))
    end
end

function way_function(node)
    -- Set a local variable to the value of the natural tag because it is being used multiple times
    local natural = Find("natural")
    -- natural=tree_row on a way is a line of trees
    if natural == "tree_row" then
        Layer("tree_lines", false)
        Attribute("leaf_type", Find("leaf_type"))
    end
    if natural == "wood" or Find("landuse") == "forest" then
        Layer("tree_areas", true)
        Attribute("leaf_type", Find("leaf_type"))
    end
end
