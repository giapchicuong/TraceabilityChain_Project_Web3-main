// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// contract Products {
//     event Added(uint256 index);
//     struct Product {
//         uint256 productId;
//         string name;
//         string description;
//         string typeProduct;
//         uint256 price;
//         string image;
//         uint256 date;
//         address userId;
//     }
//     mapping(uint256 => Product) public products;

//     uint256 public numberOfProducts = 0;
//     uint256 items = 0;

//     function createProduct(
//         string memory _name,
//         string memory _description,
//         string memory _typeProduct,
//         uint256 _price,
//         string memory _image
//     ) public returns (uint256) {
//         Product storage product = products[numberOfProducts];
//         product.productId = items;
//         product.name = _name;
//         product.description = _description;
//         product.typeProduct = _typeProduct;
//         product.price = _price;
//         product.image = _image;
//         product.date = block.timestamp;
//         product.userId = msg.sender;

//         numberOfProducts++;
//         items++;
//         emit Added(items - 1);
//         return numberOfProducts - 1;
//     }

//     function getAllProducts() public view returns (Product[] memory) {
//         Product[] memory allProducts = new Product[](numberOfProducts);
//         for (uint i = 0; i < numberOfProducts; i++) {
//             Product storage item = products[i];
//             allProducts[i] = item;
//         }
//         return allProducts;
//     }

//     function searchProduct(
//         uint _productId
//     )
//         public
//         view
//         returns (
//             string memory,
//             string memory,
//             string memory,
//             uint256,
//             string memory,
//             uint256,
//             address
//         )
//     {
//         require(_productId <= items, "Product does not exist");

//         Product storage product = products[_productId];

//         return (
//             product.name,
//             product.description,
//             product.typeProduct,
//             product.price,
//             product.image,
//             product.date,
//             product.userId
//         );
//     }
// }

pragma solidity ^0.8.9;

contract Products {
    constructor() {}
    struct Product {
        address owner;
        uint96 id;
        uint96 userID;
        string name;
        string description;
        uint256 price;
        uint256 date;
        string image;
        string typeProduct;
        uint256 updateAt;
        uint256 createAt;
        bool isVisible;
    }

    mapping(uint96 => uint256[]) public idToProductIndices;
    mapping(uint96 => uint256[]) public userIdToProductIndices;
    mapping(uint256 => Product) public products;

    uint256 public productCount = 0;
    uint256 public productIsHidden = 0;
    uint96 public codeIDCounter = 0;

    function createProduct(
        uint96 _userID,
        string memory _name,
        uint256 _price,
        string memory _description,
        uint256 _date,
        string memory _image,
        string memory _typeProduct
    ) public {
        Product memory newProduct = Product({
            owner: msg.sender,
            id: codeIDCounter,
            userID: _userID,
            name: _name,
            price: _price,
            description: _description,
            date: _date,
            image: _image,
            typeProduct: _typeProduct,
            updateAt: block.timestamp,
            createAt: block.timestamp,
            isVisible: true
        });

        products[codeIDCounter] = newProduct;
        idToProductIndices[codeIDCounter].push(productCount);
        userIdToProductIndices[_userID].push(productCount);
        productCount++;
        codeIDCounter++;

        emit importProduct(
            msg.sender,
            _userID,
            _name,
            _price,
            _description,
            _date,
            _image,
            _typeProduct
        );
    }

    function hiddenProduct(uint96 _productId) public returns (bool ret) {
        require(
            _productId <= productCount + 1,
            "Product index is out of range."
        );
        require(
            products[_productId].owner == msg.sender,
            "Only the owner can hide this product."
        );
        if (products[_productId].id == _productId) {
            products[_productId].isVisible = false;
            return true;
        }

        emit softDelete(msg.sender, _productId);
    }

    function searchProduct(
        uint96 _IdProduct
    ) public view returns (Product[] memory) {
        uint256[] memory indices = idToProductIndices[_IdProduct];
        Product[] memory results = new Product[](indices.length);
        uint96 countDataDisplay = 0;
        uint96 k = 0;

        for (uint i = 0; i < indices.length; i++) {
            results[i] = products[indices[i]];
            if (results[i].isVisible == true) {
                countDataDisplay++;
            }
        }
        Product[] memory dataDisplay = new Product[](countDataDisplay);

        for (uint j = 0; j < results.length; j++) {
            if (results[j].isVisible == true) {
                dataDisplay[k] = results[j];
                k++;
            }
        }
        return dataDisplay;
    }

    function getAllProducts() public view returns (Product[] memory) {
        Product[] memory allProduct = new Product[](productCount);

        for (uint i = 0; i < productCount; i++) {
            Product storage item = products[i];

            allProduct[i] = item;
        }

        return allProduct;
    }
    function getAllProductByOwner(
        address _owner
    ) public view returns (Product[] memory) {
        uint256 count = 0;
        for (uint i = 0; i < productCount; i++) {
            if (products[i].owner == _owner) {
                count++;
            }
        }

        Product[] memory ownerProducts = new Product[](count);
        uint256 index = 0;
        for (uint i = 0; i < productCount; i++) {
            if (products[i].owner == _owner) {
                ownerProducts[index] = products[i];
                index++;
            }
        }

        return ownerProducts;
    }
    event importProduct(
        address _actorAddress,
        uint96 _userID,
        string _name,
        uint256 _price,
        string _description,
        uint256 _date,
        string _image,
        string _typeProduct
    );

    event softDelete(address actorAddress, uint96 _productId);
}
