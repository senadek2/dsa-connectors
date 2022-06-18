//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/**
 * @title Aave v2.
 * @dev Lending & Borrowing.
 */

import { TokenInterface } from "../../../common/interfaces.sol";
import { Stores } from "../../../common/stores.sol";
import { Helpers } from "./helpers.sol";
import { Events } from "./events.sol";
import { AaveInterface } from "./interface.sol";

abstract contract AaveResolver is Events, Helpers {
	/**
	 * @dev Deposit ETH/ERC20_Token.
	 * @notice Deposit a token to Aave v2 for lending / collaterization.
	 * @param token The address of the token to deposit.(For MATIC: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param amt The amount of the token to deposit. (For max: `uint256(-1)`)
	 * @param getId ID to retrieve amt.
	 * @param setId ID stores the amount of tokens deposited.
	 */
	function deposit(
		address token,
		uint256 amt,
		uint256 getId,
		uint256 setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(getId, amt);

		AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());

		bool isEth = token == maticAddr;
		address _token = isEth ? wmaticAddr : token;

		TokenInterface tokenContract = TokenInterface(_token);

		if (isEth) {
			_amt = _amt == uint256(-1) ? address(this).balance : _amt;
			convertMaticToWmatic(isEth, tokenContract, _amt);
		} else {
			_amt = _amt == uint256(-1)
				? tokenContract.balanceOf(address(this))
				: _amt;
		}

		approve(tokenContract, address(aave), _amt);

		aave.deposit(_token, _amt, address(this), referralCode);

		if (!getIsColl(_token)) {
			aave.setUserUseReserveAsCollateral(_token, true);
		}

		setUint(setId, _amt);

		_eventName = "LogDeposit(address,uint256,uint256,uint256)";
		_eventParam = abi.encode(token, _amt, getId, setId);
	}

	/**
	 * @dev Withdraw ETH/ERC20_Token.
	 * @notice Withdraw deposited token from Aave v2
	 * @param token The address of the token to withdraw.(For MATIC: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param amt The amount of the token to withdraw. (For max: `uint256(-1)`)
	 * @param getId ID to retrieve amt.
	 * @param setId ID stores the amount of tokens withdrawn.
	 */
	function withdraw(
		address token,
		uint256 amt,
		uint256 getId,
		uint256 setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(getId, amt);

		AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());
		bool isEth = token == maticAddr;
		address _token = isEth ? wmaticAddr : token;

		TokenInterface tokenContract = TokenInterface(_token);

		uint256 initialBal = tokenContract.balanceOf(address(this));
		aave.withdraw(_token, _amt, address(this));
		uint256 finalBal = tokenContract.balanceOf(address(this));

		_amt = sub(finalBal, initialBal);

		convertWmaticToMatic(isEth, tokenContract, _amt);

		setUint(setId, _amt);

		_eventName = "LogWithdraw(address,uint256,uint256,uint256)";
		_eventParam = abi.encode(token, _amt, getId, setId);
	}

	/**
	 * @dev Borrow ETH/ERC20_Token.
	 * @notice Borrow a token using Aave v2
	 * @param token The address of the token to borrow.(For MATIC: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param amt The amount of the token to borrow.
	 * @param rateMode The type of borrow debt. (For Stable: 1, Variable: 2)
	 * @param getId ID to retrieve amt.
	 * @param setId ID stores the amount of tokens borrowed.
	 */
	function borrow(
		address token,
		uint256 amt,
		uint256 rateMode,
		uint256 getId,
		uint256 setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(getId, amt);

		AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());

		bool isEth = token == maticAddr;
		address _token = isEth ? wmaticAddr : token;

		aave.borrow(_token, _amt, rateMode, referralCode, address(this));
		convertWmaticToMatic(isEth, TokenInterface(_token), _amt);

		setUint(setId, _amt);

		_eventName = "LogBorrow(address,uint256,uint256,uint256,uint256)";
		_eventParam = abi.encode(token, _amt, rateMode, getId, setId);
	}

	/**
	 * @dev Payback borrowed ETH/ERC20_Token.
	 * @notice Payback debt owed.
	 * @param token The address of the token to payback.(For MATIC: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param amt The amount of the token to payback. (For max: `uint256(-1)`)
	 * @param rateMode The type of debt paying back. (For Stable: 1, Variable: 2)
	 * @param getId ID to retrieve amt.
	 * @param setId ID stores the amount of tokens paid back.
	 */
	function payback(
		address token,
		uint256 amt,
		uint256 rateMode,
		uint256 getId,
		uint256 setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(getId, amt);

		AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());

		bool isMatic = token == maticAddr;
		address _token = isMatic ? wmaticAddr : token;

		TokenInterface tokenContract = TokenInterface(_token);

		if (_amt == uint256(-1)) {
			uint256 _amtDSA = isMatic
				? address(this).balance
				: tokenContract.balanceOf(address(this));
			uint256 _amtDebt = getPaybackBalance(_token, rateMode);
			_amt = _amtDSA <= _amtDebt ? _amtDSA : _amtDebt;
		}

		if (isMatic) convertMaticToWmatic(isMatic, tokenContract, _amt);

		approve(tokenContract, address(aave), _amt);

		aave.repay(_token, _amt, rateMode, address(this));

		setUint(setId, _amt);

		_eventName = "LogPayback(address,uint256,uint256,uint256,uint256)";
		_eventParam = abi.encode(token, _amt, rateMode, getId, setId);
	}

	/**
	 * @dev Payback borrowed MATIC/ERC20_Token on behalf of a user.
	 * @notice Payback debt owed on behalf os a user.
	 * @param token The address of the token to payback.(For AVAX: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param amt The amount of the token to payback. (For max: `uint256(-1)`)
	 * @param rateMode The type of debt paying back. (For Stable: 1, Variable: 2)
	 * @param onBehalfOf Address of user who's debt to repay.
	 * @param getId ID to retrieve amt.
	 * @param setId ID stores the amount of tokens paid back.
	 */
	function paybackOnBehalfOf(
		address token,
		uint256 amt,
		uint256 rateMode,
		address onBehalfOf,
		uint256 getId,
		uint256 setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(getId, amt);

		AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());

		bool isMatic = token == maticAddr;
		address _token = isMatic ? wmaticAddr : token;

		TokenInterface tokenContract = TokenInterface(_token);

		if (_amt == uint256(-1)) {
			uint256 _amtDSA = isMatic
				? address(this).balance
				: tokenContract.balanceOf(address(this));
			uint256 _amtDebt = getOnBehalfOfPaybackBalance(
				_token,
				rateMode,
				onBehalfOf
			);
			_amt = _amtDSA <= _amtDebt ? _amtDSA : _amtDebt;
		}

		if (isMatic) convertMaticToWmatic(isMatic, tokenContract, _amt);

		approve(tokenContract, address(aave), _amt);

		aave.repay(_token, _amt, rateMode, onBehalfOf);

		setUint(setId, _amt);

		_eventName = "LogPaybackOnBehalfOf(address,uint256,uint256,address,uint256,uint256)";
		_eventParam = abi.encode(
			token,
			_amt,
			rateMode,
			onBehalfOf,
			getId,
			setId
		);
	}

	/**
	 * @dev Enable collateral
	 * @notice Enable an array of tokens as collateral
	 * @param tokens Array of tokens to enable collateral
	 */
	function enableCollateral(address[] calldata tokens)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _length = tokens.length;
		require(_length > 0, "0-tokens-not-allowed");

		AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());

		for (uint256 i = 0; i < _length; i++) {
			bool isMatic = tokens[i] == maticAddr;
		    address _token = isMatic ? wmaticAddr : tokens[i];

			if (getCollateralBalance(_token) > 0 && !getIsColl(_token)) {
				aave.setUserUseReserveAsCollateral(_token, true);
			}
		}

		_eventName = "LogEnableCollateral(address[])";
		_eventParam = abi.encode(tokens);
	}

    /**
     * @dev Swap borrow rate mode
     * @notice Swaps user borrow rate mode between variable and stable
     * @param token The address of the token to swap borrow rate.(For MATIC: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
     * @param currentRateMode Current Rate mode. (Stable = 1, Variable = 2)
    */
    function swapBorrowRateMode(
        address token,
        uint currentRateMode
    ) external payable returns (string memory _eventName, bytes memory _eventParam) {
        AaveInterface aave = AaveInterface(aaveProvider.getLendingPool());

		bool isMatic = token == maticAddr;
		address _token = isMatic ? wmaticAddr : token;

        if (getPaybackBalance(_token, currentRateMode) > 0) {
            aave.swapBorrowRateMode(_token, currentRateMode);
        }

        _eventName = "LogSwapRateMode(address,uint256)";
        _eventParam = abi.encode(token, currentRateMode);
    }
}

contract ConnectV2AaveV2Polygon is AaveResolver {
	string public constant name = "AaveV2-v1.1";
}
