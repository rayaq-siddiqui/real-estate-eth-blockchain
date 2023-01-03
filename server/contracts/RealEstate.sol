// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract RealEstate {
    // Struct to represent a property listing
    struct Property {
        address payable owner;
        uint price;
        string location;
        string features;
        bool forSale;
    }

    address marketOwner;

    // Mapping from property ID to property information
    mapping(uint => Property) public properties;

    // Counter to generate unique property IDs
    uint public propertyCount;

    // constructor
    constructor() public {
        propertyCount = 0;
        marketOwner = msg.sender;
    }

    // Function to create a new property listing
    function createProperty(uint _price, string memory _location, string memory _features) public {
        require(msg.sender == marketOwner, "You do not have access to create more properties");

        // Increment the property count and use it as the ID for the new property
        propertyCount++;
        uint propertyId = propertyCount;

        // Create a new property listing and set the owner to the caller
        properties[propertyId] = Property(msg.sender, _price, _location, _features, true);
    }

    // Function to make an offer on a property
    function makeOffer(uint _propertyId, uint _offer) public payable {
        // Retrieve the property information
        Property storage property = properties[_propertyId];

        // Check that the property is for sale and that the offer is valid
        require(property.forSale, "Property is not for sale");
        require(_offer >= property.price, "Offer is not sufficient");

        // Transfer ownership of the property to the caller and release the payment to the seller
        property.owner = msg.sender;
        property.forSale = false;
        property.owner.transfer(property.price);
    }

    // Function to update the properties of a property listing
    function updateProperty(uint _propertyId, uint _price, string memory _location, string memory _features, bool _forSale) public {
        // Retrieve the property information
        Property storage property = properties[_propertyId];

        // Check that the caller is the owner of the property
        require(property.owner == msg.sender, "Only the owner can update the property");

        // Update the properties of the property listing
        property.price = _price;
        property.location = _location;
        property.features = _features;
        property.forSale = _forSale;
    }
}
