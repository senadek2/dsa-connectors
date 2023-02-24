//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "./helpers.sol";
import "./events.sol";

abstract contract MorphoAaveV3 is Helpers, Events {
	/**
	 * @dev Deposit ETH/ERC20_Token.
	 * @notice Deposit a token to Morpho Aave for lending / collaterization.
	 * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens deposited.
	 */
	function deposit(
		address _tokenAddress,
		uint256 _amount,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		(
			TokenInterface _tokenContract,
			uint256 _amt
		) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.supply(_tokenContract, _amt, address(this), MAX_ITERATION);

		setUint(_setId, _amt);

		_eventName = "LogDeposit(address,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Deposit ETH/ERC20_Token.
	 * @notice Deposit a token to Morpho Aave for lending / collaterization.
	 * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	 * @param _onBehalf The address of user on behalf to deposit.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens deposited.
	 */
	function depositWithMaxIterations(
		address _tokenAddress,
		uint256 _amount,
		address _onBehalf,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		(
			TokenInterface _tokenContract,
			uint256 _amt
		) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.supply(_tokenContract, _amt, _onBehalf, MAX_ITERATION);

		setUint(_setId, _amt);

		_eventName = "LogDepositWithMaxIterations(address,uint256,address,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_onBehalf,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Deposit ETH/ERC20_Token on behalf of a user.
	 * @notice Deposit a token to Morpho Aave for lending / collaterization on behalf of a user.
	 * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	 * @param _onBehalf The address of user on behalf to deposit.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens deposited.
	 */
	function depositOnBehalf(
		address _tokenAddress,
		uint256 _amount,
		address _onBehalf,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		(
			TokenInterface _tokenContract,
			uint256 _amt
		) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.supply(_tokenContract, _amt, _onBehalf, MAX_ITERATION);

		setUint(_setId, _amt);

		_eventName = "LogDepositOnBehalf(address,uint256,address,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_onBehalf,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Deposit ETH/ERC20_Token on behalf of a user.
	 * @notice Deposit a token to Morpho Aave for lending / collaterization on behalf of a user.
	 * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	 * @param _onBehalf The address of user on behalf to deposit.
	 * @param _onBehalf The address of user on behalf to deposit.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens deposited.
	 */
	function depositOnBehalfWithMaxIterations (
		address _tokenAddress,
		uint256 _amount,
		address _onBehalf,
		uint256 _maxIteration,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		(
			TokenInterface _tokenContract,
			uint256 _amt
		) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.supply(_tokenContract, _amt, _onBehalf, _maxIteration);

		setUint(_setId, _amt);

		_eventName = "LogDepositOnBehalfWithMaxIterations(address,uint256,address,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_onBehalf,
			_maxIteration,
			_getId,
			_setId
		);
	}

	// /**
	//  * @notice Supplies `amount` of `underlying` of `onBehalf` using permit2 in a single tx.
	//  * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	//  * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	//  * @param _onBehalf The address of user on behalf to deposit.
	//  * @param _maxIterations The maximum number of iterations allowed during the matching process.
	//  * @param _signature The permit2 signature.
	//  * @param _getId ID to retrieve amt.
	//  * @param _setId ID stores the amount of tokens deposited.
	//  */
	// function depositWithPermit(
	// 	address _tokenAddress,
	// 	uint256 _amount,
	// 	address _onBehalf,
	// 	uint256 _maxIterations,
	// 	Signature calldata _signature,
	// 	uint256 _getId,
	// 	uint256 _setId
	// )
	// 	external
	// 	payable
	// 	returns (string memory _eventName, bytes memory _eventParam)
	// {
	// 	(
	// 		TokenInterface _tokenContract,
	// 		uint256 _amt
	// 	) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

	// 	approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

	// 	MORPHO_AAVE_V3.supplyWithPermit(_tokenContract, _amt, _onBehalf, _maxIterations, block.timestamp, _signature);

	// 	setUint(_setId, _amt);

	// 	_eventName = "LogDepositWithPermit(address,uint256,address,uint256,uint256,uint8,bytes32,bytes32,uint256,uint256)";
	// 	_eventParam = abi.encode(
	// 		_tokenAddress,
	// 		_amt,
	// 		_onBehalf,
	// 		_maxIterations,
	// 		block.timestamp,
	// 		_signature.v,
	// 		_signature.r,
	// 		_signature.s,
	// 		_getId,
	// 		_setId
	// 	);
	// }

	/**
	 * @dev Deposit ETH/ERC20_Token on behalf of a user.
	 * @notice Deposit a token to Morpho Aave for lending / collaterization on behalf of a user.
	 * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens deposited.
	 */
	function depositCollateral(
		address _tokenAddress,
		uint256 _amount,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		(
			TokenInterface _tokenContract,
			uint256 _amt
		) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.supplyCollateral(_tokenContract, _amt, address(this));

		setUint(_setId, _amt);

		_eventName = "LogDepositCollateral(address,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Deposit ETH/ERC20_Token on behalf of a user.
	 * @notice Deposit a token to Morpho Aave for lending / collaterization on behalf of a user.
	 * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	 * @param _onBehalf The address of user on behalf to deposit.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens deposited.
	 */
	function depositCollateralOnBehalf(
		address _tokenAddress,
		uint256 _amount,
		address _onBehalf,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		(
			TokenInterface _tokenContract,
			uint256 _amt
		) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.supplyCollateral(_tokenContract, _amt, _onBehalf);

		setUint(_setId, _amt);

		_eventName = "LogDepositCollateralOnBehalf(address,uint256,address,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_onBehalf,
			_getId,
			_setId
		);
	}

	// /**
	//  * @notice Supplies `amount` of `underlying` of `onBehalf` using permit2 in a single tx.
	//  * @param _tokenAddress The address of underlying token to deposit.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	//  * @param _amount The amount of the token (in underlying) to deposit. (For max: `uint256(-1)`)
	//  * @param _onBehalf The address of user on behalf to deposit.
	//  * @param _signature The permit2 signature.
	//  * @param _getId ID to retrieve amt.
	//  * @param _setId ID stores the amount of tokens deposited.
	//  */
	// function depositCollateralWithPermit(
	// 	address _tokenAddress,
	// 	uint256 _amount,
	// 	address _onBehalf,
	// 	Signature calldata _signature,
	// 	uint256 _getId,
	// 	uint256 _setId
	// )
	// 	external
	// 	payable
	// 	returns (string memory _eventName, bytes memory _eventParam)
	// {
	// 	(
	// 		TokenInterface _tokenContract,
	// 		uint256 _amt
	// 	) = _performEthToWethConversion(_tokenAddress, _amount, _getId);

	// 	approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

	// 	MORPHO_AAVE_V3.supplyCollateralWithPermit(_tokenContract, _amt, _onBehalf, block.timestamp, _signature);

	// 	setUint(_setId, _amt);

	// 	_eventName = "LogDepositCollateralWithPermit(address,uint256,address,uint256,uint8,bytes32,bytes32,uint256,uint256)";
	// 	_eventParam = abi.encode(
	// 		_tokenAddress,
	// 		_amt,
	// 		_onBehalf,
	// 		block.timestamp,
	// 		_signature.v,
	// 		_signature.r,
	// 		_signature.s,
	// 		_getId,
	// 		_setId
	// 	);
	// }

	/**
	 * @dev Borrow ETH/ERC20_Token.
	 * @notice Borrow a token from Morpho Aave.
	 * @param _tokenAddress The address of underlying token to borrow.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to borrow.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens borrowed.
	 */
	function borrow(
		address _tokenAddress,
		uint256 _amount,
		address _receiver,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(_getId, _amount);

		MORPHO_AAVE_V3.borrow(_tokenAddress, _amt, address(this), _receiver, MAX_ITERATION);

		convertWethToEth(_tokenAddress == ethAddr, TokenInterface(wethAddr), _amt);

		setUint(_setId, _amt);

		_eventName = "LogBorrow(address,uint256,address,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_receiver,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Borrow ETH/ERC20_Token.
	 * @notice Borrow a token from Morpho Aave.
	 * @param _tokenAddress The address of underlying token to borrow.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to borrow.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens borrowed.
	 */
	function borrowOnBehalf(
		address _tokenAddress,
		uint256 _amount,
		address _receiver,
		address _onBehalf,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(_getId, _amount);

		MORPHO_AAVE_V3.borrow(_tokenAddress, _amt, address(this), _receiver, MAX_ITERATION);

		convertWethToEth(_tokenAddress == ethAddr, _onBehalf, _amt);

		setUint(_setId, _amt);

		_eventName = "LogBorrowOnBehalf(address,uint256,addresss,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_receiver,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Borrow ETH/ERC20_Token.
	 * @notice Borrow a token from Morpho Aave.
	 * @param _tokenAddress The address of underlying token to borrow.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to borrow.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens borrowed.
	 */
	function borrowWithMaxIterations(
		address _tokenAddress,
		uint256 _amount,
		address _receiver,
		uint256 _maxIteration,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(_getId, _amount);

		MORPHO_AAVE_V3.borrow(_tokenAddress, _amt, address(this), _receiver, _maxIteration);

		convertWethToEth(_tokenAddress == ethAddr, address(this), _amt);

		setUint(_setId, _amt);

		_eventName = "LogBorrowWithMaxIterations(address,uint256,addresss,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_receiver,
			_maxIteration,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Borrow ETH/ERC20_Token.
	 * @notice Borrow a token from Morpho Aave.
	 * @param _tokenAddress The address of underlying token to borrow.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _amount The amount of the token (in underlying) to borrow.
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens borrowed.
	 */
	function borrowOnBehalfWithMaxIterations (
		address _tokenAddress,
		uint256 _amount,
		address _onBehalf,
		address _receiver,
		uint256 _maxIteration,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(_getId, _amount);

		MORPHO_AAVE_V3.borrow(_tokenAddress, _amt, _onBehalf, _receiver, _maxIteration);

		convertWethToEth(_tokenAddress == ethAddr, _onBehalf, _amt);

		setUint(_setId, _amt);

		_eventName = "LogBorrowOnBehalfWithMaxIterations(address,uint256,addresss,address,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_amt,
			_receiver,
			_maxIteration,
			_getId,
			_setId
		);
	}

	// /**
	//  * @dev Borrow ETH/ERC20_Token with max gas.
	//  * @notice Borrow a token from Morpho Aave with max gas.
	//  * @param _tokenAddress The address of underlying token to borrow.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE).
	//  * @param _poolTokenAddress The address of aToken to borrow.(For ETH: aWETH address).
	//  * @param _amount The amount of the token (in underlying) to borrow.
	//  * @param _maxGasForMatching The maximum amount of gas to consume within a matching engine loop.
	//  * @param _getId ID to retrieve amt.
	//  * @param _setId ID stores the amount of tokens borrowed.
	//  */
	// function borrowWithMaxGas(
	// 	address _tokenAddress,
	// 	address _poolTokenAddress,
	// 	uint256 _amount,
	// 	uint256 _maxGasForMatching,
	// 	uint256 _getId,
	// 	uint256 _setId
	// )
	// 	external
	// 	payable
	// 	returns (string memory _eventName, bytes memory _eventParam)
	// {
	// 	uint256 _amt = getUint(_getId, _amount);

	// 	MORPHO_AAVE_V3.borrow(_poolTokenAddress, _amt, _maxGasForMatching);

	// 	convertWethToEth(_tokenAddress == ethAddr, TokenInterface(wethAddr), _amt);

	// 	setUint(_setId, _amt);

	// 	_eventName = "LogBorrowWithMaxGas(address,address,uint256,uint256,uint256,uint256)";
	// 	_eventParam = abi.encode(
	// 		_tokenAddress,
	// 		_poolTokenAddress,
	// 		_amt,
	// 		_maxGasForMatching,
	// 		_getId,
	// 		_setId
	// 	);
	// }

	/**
	 * @dev Withdraw ETH/ERC20_Token.
	 * @notice Withdraw a token from Morpho Aave.
	 * @param _tokenAddress The address of underlying token to withdraw.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _poolTokenAddress The address of aToken to withdraw.(For ETH: aWETH address)
	 * @param _amount The amount of the token (in underlying) to withdraw. (For max: `uint256(-1)`)
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens withdrawed.
	 */
	function withdraw(
		address _tokenAddress,
		address _poolTokenAddress,
		uint256 _amount,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		uint256 _amt = getUint(_getId, _amount);
		if (_amt == uint256(-1))
			(, , _amt) = MORPHO_AAVE_LENS.getCurrentSupplyBalanceInOf(
				_poolTokenAddress,
				address(this)
			);

		MORPHO_AAVE_V3.withdraw(_poolTokenAddress, _amt);

		convertWethToEth(_tokenAddress == ethAddr, TokenInterface(wethAddr), _amt);

		setUint(_setId, _amt);

		_eventName = "LogWithdraw(address,address,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_poolTokenAddress,
			_amt,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Payback ETH/ERC20_Token.
	 * @notice Payback a token to Morpho Aave.
	 * @param _tokenAddress The address of underlying token to payback.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _poolTokenAddress The address of aToken to payback.(For ETH: aWETH address)
	 * @param _amount The amount of the token (in underlying) to payback. (For max: `uint256(-1)`)
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens paid back.
	 */
	function payback(
		address _tokenAddress,
		address _poolTokenAddress,
		uint256 _amount,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		bool _isETH = _tokenAddress == ethAddr;
		uint256 _amt = getUint(_getId, _amount);

		TokenInterface _tokenContract = _isETH
			? TokenInterface(wethAddr)
			: TokenInterface(_tokenAddress);

		if (_amt == uint256(-1)) {
			uint256 _amtDSA = _isETH
				? address(this).balance
				: _tokenContract.balanceOf(address(this));

			(, , uint256 _amtDebt) = MORPHO_AAVE_LENS
				.getCurrentBorrowBalanceInOf(_poolTokenAddress, address(this));

			_amt = _amtDSA < _amtDebt ? _amtDSA : _amtDebt;
		}

		convertEthToWeth(_isETH, _tokenContract, _amt);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.repay(_poolTokenAddress, address(this), _amt);

		setUint(_setId, _amt);

		_eventName = "LogPayback(address,address,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_poolTokenAddress,
			_amt,
			_getId,
			_setId
		);
	}

	/**
	 * @dev Payback ETH/ERC20_Token.
	 * @notice Payback a token to Morpho Aave.
	 * @param _tokenAddress The address of underlying token to payback.(For ETH: 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
	 * @param _poolTokenAddress The address of aToken to payback.(For ETH: aWETH address)
	 * @param _onBehalf The address of user who's debt to repay.
	 * @param _amount The amount of the token (in underlying) to payback. (For max: `uint256(-1)`)
	 * @param _getId ID to retrieve amt.
	 * @param _setId ID stores the amount of tokens paid back.
	 */
	function paybackOnBehalf(
		address _tokenAddress,
		address _poolTokenAddress,
		address _onBehalf,
		uint256 _amount,
		uint256 _getId,
		uint256 _setId
	)
		external
		payable
		returns (string memory _eventName, bytes memory _eventParam)
	{
		bool _isETH = _tokenAddress == ethAddr;
		uint256 _amt = getUint(_getId, _amount);

		TokenInterface _tokenContract = _isETH
			? TokenInterface(wethAddr)
			: TokenInterface(_tokenAddress);

		if (_amt == uint256(-1)) {
			uint256 _amtDSA = _isETH
				? address(this).balance
				: _tokenContract.balanceOf(address(this));

			(, , uint256 _amtDebt) = MORPHO_AAVE_LENS
				.getCurrentBorrowBalanceInOf(_poolTokenAddress, _onBehalf);

			_amt = _amtDSA < _amtDebt ? _amtDSA : _amtDebt;
		}

		convertEthToWeth(_isETH, _tokenContract, _amt);

		approve(_tokenContract, address(MORPHO_AAVE_V3), _amt);

		MORPHO_AAVE_V3.repay(_poolTokenAddress, _onBehalf, _amt);

		setUint(_setId, _amt);

		_eventName = "LogPaybackOnBehalf(address,address,address,uint256,uint256,uint256)";
		_eventParam = abi.encode(
			_tokenAddress,
			_poolTokenAddress,
			_onBehalf,
			_amt,
			_getId,
			_setId
		);
	}
}

contract ConnectV3MorphoAaveV3 is MorphoAaveV3 {
	string public constant name = "Morpho-AaveV3-v1.0";
}
