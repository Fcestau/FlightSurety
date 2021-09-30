pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    mapping(address => bool) private authorizedCallers;                               
    
    struct Airline {
        address airlineAddress;
        bool registered;
        string name;
        uint256 funds;
        uint256 votes;
    }

    mapping(address => Airline) internal airlines;
    uint256 internal approvedAirlines = 0;

    uint8 private constant MULTIPARTY_MIN_AIRLINES = 4;
    uint256 public constant MIN_FUNDS = 10 ether;
    uint256 public constant INS_LIMIT = 1 ether;

    struct Passenger {
        address passengerAddress;
        mapping(string => uint256) flight;
        uint256 credit;
    }

    mapping(address => Passenger) private passengers;
    address[] public passengerAddresses;

    event AirlineRegisterd(address airline);
    event InsuredCredited(string flight);
    event WithdrawalOfCredits(address passenger);
    

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor() public {
        contractOwner = msg.sender;
        authorizedCallers[msg.sender] = true;
        airlines[contractOwner] = Airline({airlineAddress: contractOwner, registered: true, name: "First Airline", funds:0, votes: 0});
        approvedAirlines++;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier isCallerAuthorized()
    {
        require(authorizedCallers[msg.sender] || (msg.sender == contractOwner), "Caller not authorized");
        _;
    }

    modifier hasSufficientFunds(address passenger) {
         require(passengers[passenger].credit > 0, "Not enough funds to withdraw");
         _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

     function setCallerAuthorizationStatus(address caller, bool status) external requireContractOwner returns (bool) {
        authorizedCallers[caller] = status;
        return authorizedCallers[caller];
    }

    function getCallerAuthorizationStatus(address caller) public view requireContractOwner returns (bool) {
        return authorizedCallers[caller];
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function isRegistered(address airline) public view returns(bool) {
        return (airlines[airline].registered);
    }

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline(address airlineAddress, string name) external 
        requireIsOperational 
        isCallerAuthorized {
        require(airlineAddress != address(0), "Invalid address");
        require(!airlines[airlineAddress].registered, "Address already registered");

        if (approvedAirlines < MULTIPARTY_MIN_AIRLINES) {
            airlines[airlineAddress] = Airline({airlineAddress: airlineAddress, registered: true, name: name, funds: 0, votes: 1});
        } else {
            require(vote(airlineAddress), "An error ocurred during voting");
        }

    }

    function vote(address airlineAddress) internal requireIsOperational returns(bool) {
        bool voted = false;
        airlines[airlineAddress].votes++;
        if(airlines[airlineAddress].votes >= approvedAirlines.div(2)) {
            airlines[airlineAddress].registered = true;
            approvedAirlines++;
            return true;
        }
        voted = true;
        return voted;
    }

    // Returns the state of the a
    function airlineIsParticipating(address airlineAddress) public view returns(bool) {
        return(airlines[airlineAddress].funds >= MIN_FUNDS);
    }


    function exist(address passenger) internal view returns(bool inList){
        inList = false;
        for (uint256 i = 0; i < passengerAddresses.length; i++) {
            if (passengerAddresses[i] == passenger) {
                inList = true;
                break;
            }
        }
        return inList;
    }

   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy(string flight) external payable requireIsOperational {
        require(msg.value > 0, "Not enough funds");
        
        if(!exist(msg.sender)){
            passengerAddresses.push(msg.sender);
        }
        if (passengers[msg.sender].passengerAddress != msg.sender) {
            passengers[msg.sender] = Passenger({passengerAddress: msg.sender, credit: 0});
            passengers[msg.sender].flight[flight] = msg.value;
        } else {
            passengers[msg.sender].flight[flight] = msg.value;
        }
        if (msg.value > INS_LIMIT) {
            uint256 returnAmount = msg.value.sub(INS_LIMIT);
            msg.sender.transfer(returnAmount);
        }

    }
    

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees(string flight) external requireIsOperational {
        for (uint256 c = 0; c < passengerAddresses.length; c++) {
            if (passengers[passengerAddresses[c]].flight[flight] > 0) {
                uint256 insuredAmount = passengers[passengerAddresses[c]].flight[flight];
                uint256 currentAmount = passengers[passengerAddresses[c]].credit;
                // Clear the flight insured amount.
                passengers[passengerAddresses[c]].flight[flight] = 0;
                // Credit  1.5x of the insured amount 
                uint256 repaymentAmount = insuredAmount + insuredAmount.div(2);
                passengers[passengerAddresses[c]].credit = currentAmount.add(repaymentAmount);
            }
        }
        emit InsuredCredited(flight);
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay(address passenger) external requireIsOperational hasSufficientFunds(passenger) returns(address, uint256) {
        uint256 amount =  passengers[passenger].credit;
        passengers[passenger].credit = 0;
        passenger.transfer(amount);
        emit WithdrawalOfCredits(passenger);
        return (passenger, amount);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund() public payable requireIsOperational {
        uint256 funds = airlines[msg.sender].funds;
        airlines[msg.sender].funds = funds.add(msg.value);
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }


}

