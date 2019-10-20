import React from "react";
import getContractInstance from './utils.js';
import Travel from "./contracts/Travel.json";

import {
  Row,
  Col,
  Container,
  Button,
  FormInput,
  Collapse,
  Card,
  CardFooter,
  CardBody,
  CardTitle,
  CardHeader,
  CardImg,
  Badge
} from 'shards-react';

export default class TrackArtifact extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      posts : [],
      contract : null,
      accounts: null,
      web3: null,
    };

    this.toggle = this.toggle.bind(this);
    //this.runExample = this.runExample.bind(this);
  }

  toggle() {
    this.setState({ collapse: !this.state.collapse });
  }

  componentDidMount = async () => {
    const obj = await getContractInstance();
    const accounts = obj.accounts;
    const contract = obj.contract;
    console.log(contract);
    let count = await contract.methods.listSellable().call({ from: accounts[0] });
    console.log('This is count selleable');
    console.log(count);
    let responses = [];
    let lngth = count.length;
    for(let i=0;i<lngth;i++){
      let response = await contract.methods.getProduct(count[i]).call({from: accounts[0]});
      responses.push(response);
    }
    console.log(responses);
    this.setState({ posts:responses, web3:obj.web3, accounts:obj.accounts, contract: obj.contract});
  }

  handleVote = async(event) => {
    const action = event.target.value;
    const { accounts, contract } = this.state;
    if (action === "buy"){
      await contract.methods.buy(event.target.id).send({ from: accounts[0], value:parseInt(event.target.getAttribute('price')) });
    }
    else {
      await contract.methods.downvote(event.target.id).send({ from: accounts[0] });
    }
  }

  render(){
    const listItems = this.state.posts.map((item, index) =>
    <Col sm="12" md="4">
      <Card>
      <CardHeader>{JSON.parse(item._description).subject}</CardHeader>
      <CardImg width="100%" src={"https://ipfs.io/ipfs/" +(JSON.parse(item._description).ipfsId)} />
      <CardBody>
        <p>Place Added By Name :- {item._owner}</p>
        <hr/>
        <p>Price :- {item._price}</p>
        <hr />
        <p>Quantity :- {item._price} (In Tons)</p>
        <hr />
        <p>Type :- {JSON.parse(item._description).type}</p>
        <hr />
        <p>{JSON.parse(item._description).details}</p>
        <hr />
        <Button price={item._price} id={item._Id} theme="success" value="buy" onClick={this.handleVote}>Buy</Button>
        <Button price={item._price} id={item._Id} theme="danger" value="no" onClick={this.handleVote}>See More</Button>
      </CardBody>
    </Card>
    </Col>
  )
    return(
      <div>
        <Container className="main-container">
        <Row>
        <Col sm="12" md="12">
      <div>
        <h3>Organic Material On Sale</h3> <br />
        <Row>
        {listItems}
        </Row>
      </div>
    </Col>
    </Row>
    </Container>
  </div>
    );
  }
}
