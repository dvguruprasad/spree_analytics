function render_tree_map(list) {

    $('div#treemap-div').treemap(list, {
        backgroundColor:function (node, box) {
            return node.color;
        }
    });
}