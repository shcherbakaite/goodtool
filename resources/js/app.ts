// import "./unpoly";
import "../css/screen.scss";
import "./autocomplete.ts";
import "./search.ts";


// Add autocomplete for application tools
autocomplete_fields = document.querySelectorAll("input.autocomplete");

autocomplete_fields.forEach((element) => { 
        //console.log(element.attributes["autocomplete-url"].value);
        autocomplete(element);
});

// Add search
autocomplete_fields = document.querySelectorAll("input.search-field");

autocomplete_fields.forEach((element) => { 
        console.log(element.attributes["search-url"].value);
        search(element);
});



