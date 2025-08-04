// import "./unpoly";
import "../css/screen.scss";
import "./autocomplete.ts";


// Autocomplete for application tools
autocomplete_fields = document.querySelectorAll("input.autocomplete");

autocomplete_fields.forEach((element) => { 
        console.log(element.attributes["autocomplete-url"].value);
        
        autocomplete(element);

                // Fetches a Checkout Session and captures the client secret



        // const promise = fetch("/tool-quicksearch/123 121", {
        //     method: "GET",
        //     //headers: { "Content-Type": "application/json" },
        // })
        // .then((r) => r.json())
        // .then((r => console.log(r)));
        //.then((r) => r.clientSecret);

});

// const promise = fetch("create-checkout-session", {
//     method: "POST",
//     headers: { "Content-Type": "application/json" },
//   })
//     .then((r) => r.json())
//     .then((r) => r.clientSecret);

//   

