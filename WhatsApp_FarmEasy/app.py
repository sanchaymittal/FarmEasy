from flask import Flask, request
from twilio.twiml.messaging_response import MessagingResponse
# from pymongo import MongoClient
import sqlite3
from web3 import Web3
import json
# from sqlite3 import Error

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello, World!"

@app.route("/sms", methods=['POST'])
def sms_reply():
    print('Sms came')
    """Respond to incoming calls with a simple text message."""
    # Fetch the message
    msg = request.form.get('Body')
    print('this is mesg')
    print(msg)
    cmd = msg.split(' ')[0]
    resp = MessagingResponse()
    if(cmd == "Menu"):
    	resp.message("Select one:\n1.Register\n\tExample:- Register (Your Name)\n2.Add Product\n\tExample:- Add (product) (productType rabi kahrif etc.) (current price)\n3.List products\n\t Example:- ListMine\n4.Apply for selling\n\t Sell (productID) (Expected Price)\n5.List Unsold\n\t Example:- Unsold\n6. Balance\n\t Example:- Bal")
    elif(cmd == "Register"):
        try:
            con = sqlite3.connect('file:mydatabase.db?mode=rw', uri=True)
            con.close()
        except:
            con = sqlite3.connect('mydatabase.db')
            cursorObj = con.cursor()
            cursorObj.execute("CREATE TABLE Users(phone text PRIMARY KEY, privateKey text, address text)")
            con.commit()
            con.close()
        con = sqlite3.connect('mydatabase.db')
        print(str(resp))
        cursorObj = con.cursor()
        cursorObj.execute("insert into Users values('"+request.form.get('From').split(":")[1]+"','67a8abd0e1c12c86f42a3f1e325c1090c9c1c6815716f17401aebe9e8af023d8','0x69dcc8b47a58b981474572c261ac10018c06c3c4')")
        con.commit()
        con.close()
        fromnum = request.form.get('From')
        fromnum = fromnum.split(':')
        resp.message(formnum+" Registered")
        print(request.form.get('From').split(":")[1])
    elif(cmd=="Add"):
        hash = addProduct()
        resp.message("Your transaction ID is"+hash)


    return str(resp)


    # Create reply
    # resp = MessagingResponse()
    # resp.message("You said: {}".format(msg))

    return str(resp)
# @app.route("/createTable", methods=['GET'])
# def createTable():
# 	# uri = "mongodb://krishimitra:XXuLZJJrzGK2USf332d6qUooD8CFYw828P76SDVh0Smi7DTzNCSrmszWvw9fZntnn3ZCiqt4TSWrJyI7OlVCqA==@krishimitra.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@krishimitra@"
# 	# client = MongoClient(uri, ssl=True)
# 	# db = client.qwerty
# 	# resp = db.qwerty.find({ id: "WakefieldFamily"})
# 	# for record in resp:
# 	# 	print(str(record))
# 	# 	break
# 	# return str(resp)
# 	con = sqlite3.connect('mydatabase.db')
# 	cursorObj = con.cursor()
# 	cursorObj.execute("CREATE TABLE Users(id integer PRIMARY KEY, privateKey text)")
# 	con.commit()
# 	return "asdb"
# @app.route("/insert",methods=['GET'])
# def insertValue():
# 	con = sqlite3.connect('mydatabase.db')
# 	cursorObj = con.cursor()
# 	cursorObj.execute("INSERT INTO Users VALUES(1, '67a8abd0e1c12c86f42a3f1e325c1090c9c1c6815716f17401aebe9e8af023d8')")
# 	con.commit()
# 	return "aadasd"


def addProduct():
    w3 = Web3(Web3.HTTPProvider("https://kovan.infura.io/v3/311ef590f7e5472a90edfa1316248cff"))
    w3.eth.defaultAccount = Web3.toChecksumAddress("0x69dcc8b47a58b981474572c261ac10018c06c3c4")
    ca=Web3.toChecksumAddress('0xBe94Cd32042fd54442854dE18046Cec6Deb80F48')
    abi= '''[
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "string",
        "name": "description",
        "type": "string"
      },
      {
        "internalType": "uint256",
        "name": "price",
        "type": "uint256"
      }
    ],
    "name": "addProduct",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "pID",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_sellID",
        "type": "uint256"
      }
    ],
    "name": "buy",
    "outputs": [
      {
        "internalType": "bool",
        "name": "status",
        "type": "bool"
      }
    ],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_productID",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_price",
        "type": "uint256"
      }
    ],
    "name": "listForSell",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "_sellID",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_productID",
        "type": "uint256"
      }
    ],
    "name": "getProduct",
    "outputs": [
      {
        "internalType": "string",
        "name": "_description",
        "type": "string"
      },
      {
        "internalType": "uint256",
        "name": "_price",
        "type": "uint256"
      },
      {
        "internalType": "address",
        "name": "_owner",
        "type": "address"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "address",
        "name": "_addr",
        "type": "address"
      }
    ],
    "name": "getUser",
    "outputs": [
      {
        "internalType": "uint256[]",
        "name": "_ownings",
        "type": "uint256[]"
      },
      {
        "internalType": "uint256[]",
        "name": "_purchases",
        "type": "uint256[]"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "idProductMap",
    "outputs": [
      {
        "internalType": "string",
        "name": "description",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "owner",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "price",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "idSellMap",
    "outputs": [
      {
        "internalType": "address",
        "name": "seller",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "productID",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "price",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "listSellable",
    "outputs": [
      {
        "internalType": "uint256[]",
        "name": "",
        "type": "uint256[]"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "productCount",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
"type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "selfProfile",
    "outputs": [
      {
        "internalType": "uint256[]",
        "name": "_ownings",
        "type": "uint256[]"
      },
      {
        "internalType": "uint256[]",
        "name": "_purchases",
        "type": "uint256[]"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_sellID",
        "type": "uint256"
      }
    ],
    "name": "sellDetails",
    "outputs": [
      {
        "internalType": "string",
        "name": "_description",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "_owner",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "_price",
        "type": "uint256"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  }
]'''
    Greeter = w3.eth.contract(abi=abi,address=ca)
    this=Greeter.functions
    nonce = w3.eth.getTransactionCount('0x5ce9454909639D2D17A3F753ce7d93fa0b9aB12E')
    txn = this.addProduct(
        '''{"quantity":"23","price":"456","loc":{"lat":26.9196,"lng":75.7878},"type":"rabi","subject":"Wheat","details":"This is a high quality wheat","ipfsId":"QmdTgy27ocWTwvznVqwqm91uyNmU93rhkFPWzf2Sh6TST1"}''',
        1,
    ).buildTransaction({
        'chainId': 42,
        'gas': 7000000,
        'gasPrice': w3.toWei('1', 'gwei'),
        'nonce': nonce,
    })
    private_key = b"\xb2\\}\xb3\x1f\xee\xd9\x12''\xbf\t9\xdcv\x9a\x96VK-\xe4\xc4rm\x03[6\xec\xf1\xe5\xb3d"
    signed_txn = w3.eth.account.sign_transaction(txn, private_key=private_key)
    w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    return str(w3.toHex(w3.keccak(signed_txn.rawTransaction)))


if __name__ == "__main__":
    app.run(debug=True)
