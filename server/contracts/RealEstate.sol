// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract RealEstate {
    // Struct to represent a property listing
    struct Property {
        address payable owner;
        uint price;
        uint numBed;
        uint numBath;
        string location;
        bool forSale;
    }

    // address of individual who created the RealEstate market
    address public marketOwner;

    // Mapping from property ID to property information
    uint public propertyCount;
    mapping(uint => Property) public properties;

    // constructor
    constructor() public {
        propertyCount = 0;
        marketOwner = msg.sender;

        createProperty(1 ether, 1, 1, "Toronto");
    }

    // events
    event PropertyCreated(
        uint id,
        address owner,
        uint price,
        uint numBed,
        uint numBath,
        string location,
        bool forSale
    );

    event PropertyUpdated(
        uint id,
        address owner,
        uint price,
        uint numBed,
        uint numBath,
        string location,
        bool forSale
    );

    event PropertySold(
        uint id,
        address oldOwner,
        address owner
    );

    event PropertyInfo(
        uint id,
        address owner,
        uint price,
        uint numBed,
        uint numBath,
        string location,
        bool forSale
    );

    // Function to create a new property listing
    function createProperty(uint _price, uint _numBed, uint _numBath, string memory _location) public {
        require(msg.sender == marketOwner, "You do not have access to create more properties");

        // Increment the property count and use it as the ID for the new property
        propertyCount++;
        uint propertyId = propertyCount;

        // Create a new property listing and set the owner to the caller
        address payable propertyOwner = msg.sender;
        properties[propertyId] = Property(propertyOwner, _price, _numBed, _numBath, _location, true);

        // emit event that the property is created
        emit PropertyCreated(propertyId, msg.sender, _price, _numBed, _numBath, _location, true);
    }

    // Function to make an offer on a property
    function makeOffer(uint _propertyId) public payable {
        // Retrieve the property information
        Property storage property = properties[_propertyId];

        // Check that the property is for sale and that the offer is valid
        require(property.forSale, "Property is not for sale");
        require(uint(msg.value) >= property.price, "Offer is not sufficient");

        // Transfer ownership of the property to the caller and release the payment to the seller
        address payable oldOwner = property.owner;
        oldOwner.transfer(msg.value);

        property.owner = msg.sender;
        property.forSale = false;
        property.price = uint(msg.value);

        // emit that the property has been sold
        emit PropertySold(_propertyId, oldOwner, msg.sender);
    }

    // Function to delete the property and refactor it to a small apartment (1 bed 1 bath)
    function scrapProperty(uint _propertyId) public {
        Property storage property = properties[_propertyId];

        // require to be the owner of the house
        require(property.owner == msg.sender || msg.sender == marketOwner, "Only the owner can scrap this house");

        Property memory newProperty = Property(property.owner, 1 ether, 1, 1, property.location, false);
        properties[_propertyId] = newProperty;
    }

    // Function to update the properties of a property listing
    function updateProperty(uint _propertyId, uint _price, uint _numBed, uint _numBath, string memory _location, bool _forSale) internal {
        // Retrieve the property information
        Property storage property = properties[_propertyId];

        // Check that the caller is the owner of the property
        require(property.owner == msg.sender || msg.sender == marketOwner, "Only the owner can update the property");

        // Update the properties of the property listing
        property.price = _price;
        property.numBed = _numBed;
        property.numBath = _numBath;
        property.location = _location;
        property.forSale = _forSale;

        properties[_propertyId] = property;

        // emit event that the property is updated
        emit PropertyUpdated(_propertyId, msg.sender, _price, _numBed, _numBath, _location, _forSale);
    }

    // Function to update the price of a property listing
    function updatePrice(uint _propertyId, uint _price) public {
        Property storage property = properties[_propertyId];
        updateProperty(_propertyId, _price, property.numBed, property.numBath, property.location, property.forSale);
    }

    // Function to update the location of a property listing
    function updateLocation(uint _propertyId, string memory _location) public {
        Property storage property = properties[_propertyId];
        updateProperty(_propertyId, property.price, property.numBed, property.numBath, _location, property.forSale);
    }

    // // Function to update the features of a property listing
    // function updateFeatures(uint _propertyId, string memory _features) public {
    //     Property storage property = properties[_propertyId];
    //     updateProperty(_propertyId, property.price, property.location, _features, property.forSale);
    // }

    // Function to update the forSale of a property listing
    function updateForSale(uint _propertyId, bool _forSale) public {
        Property storage property = properties[_propertyId];
        updateProperty(_propertyId, property.price, property.numBed, property.numBath, property.location, _forSale);
    }

    // Function to display the info of a property
    function getPropertyInfo(uint _propertyId) public {
        Property storage property = properties[_propertyId];
        emit PropertyInfo(_propertyId, property.owner, property.price, property.numBed, property.numBath, property.location, property.forSale);
    }
}
