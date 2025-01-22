pragma solidity ^0.8.0;

contract PredictionMarket {
    enum Outcome {
        YES,
        NO
    }

    Outcome public result; 
    uint256 public yesShares;
    uint256 public noShares;

    function buyShares(Outcome _outcome, uint256 _amount) public {
        if (_outcome == Outcome.YES) {
            yesShares += _amount;
        } else {
            noShares += _amount;
        }
    }

    function resolveMarket(Outcome _result) public {
        result = _result;
    }

    function calculatePayout(Outcome _outcome) public view returns (uint256) {
        if (result == _outcome) {
            if (result == Outcome.YES) {
                return 100 * 10**18; // 100% payout
            } else {
                return 100 * 10**18; // 100% payout
            }
        } else {
            return 0; // 0% payout
        }
    }
}