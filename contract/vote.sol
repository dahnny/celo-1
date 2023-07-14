// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Vote {
    uint private candidatesLength = 0;
    address private cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    uint private price = 1e10;
    uint private votes = 0;

    struct Candidate {
        address payable owner;
        string name;
        string image;
        string description;
        uint price;
        uint votes;
    }

    mapping(uint => Candidate) internal candidates;

    function writeCandidate(
        string memory _name,
        string memory _image,
        string memory _description
    ) public {
        candidates[candidatesLength] = Candidate(
            payable(msg.sender),
            _name,
            _image,
            _description,
            price,
            votes
        );
        candidatesLength++;
    }

    function readCandidate(
        uint _index
    )
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            string memory,
            uint,
            uint
        )
    {
        return (
            candidates[_index].owner,
            candidates[_index].name,
            candidates[_index].image,
            candidates[_index].description,
            candidates[_index].price,
            candidates[_index].votes
        );
    }

    function vote(uint _index) public payable {
        require(_index < candidatesLength, "Invalid candidate index");

        Candidate storage candidate = candidates[_index];
        require(
            msg.sender != candidate.owner,
            "Creator cannot vote for themselves"
        );

        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                candidate.owner,
                candidate.price
            ),
            "Transfer failed."
        );

        candidate.votes++;
    }

    function cancelVote(uint _index) public {
        require(_index < candidatesLength, "Invalid candidate index");
        require(candidates[_index].votes > 0, "No votes to cancel");

        candidates[_index].votes--;
    }

    function getCandidatesLength() public view returns (uint) {
        return (candidatesLength);
    }
}
