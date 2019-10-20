import React from "react";
import { Collapse,Container,Row, FormInput, Button,Col, Card,CardHeader,CardTitle,CardBody,FormTextarea,Badge, FormSelect } from "shards-react";
import Travel from "./contracts/Travel.json";
import getContractInstance from './utils.js';
import { Map, TileLayer, Marker, Popup } from 'react-leaflet';
var ipfsClient = require('ipfs-http-client')

type State = {
  hasLocation: boolean,
  latlng: {
    lat: number,
    lng: number,
  },
}

export default class CreateReview extends React.Component<{}, State> {

  captureFile (event) {
    event.stopPropagation()
    event.preventDefault()
    this.setState({added_file_hash: event.target.files});
  }

  runExample = async () => {
    console.log(this.state);
    var ipfs = ipfsClient('ipfs.infura.io', '5001', { protocol: 'https' });
    let ipfsId;
    ipfs.add([...this.state.added_file_hash], { progress: (prog) => console.log(`received: ${prog}`) })
      .then((response) => {
        console.log(response);
        ipfsId = response[0].hash;
        console.log(ipfsId);
        ( async () => {
            const { accounts, contract } = this.state;
            let content = JSON.stringify({'quantity':this.state.quantity,'price':this.state.price,'loc':this.state.latlng,'type':this.state.type,'subject':this.state.subject,'details':this.state.details,'ipfsId':ipfsId});
            console.log('This is content');
            console.log(content);
            await contract.methods.addProduct(content, this.state.price).send({ from: accounts[0] });
        })();
        this.setState({});
      }).catch((err) => {
        console.error(err);
      });

      console.log(this.state.latlng);
    //this.setState({subject:'',details:'',name:''}, this.getApplications);
  };

  componentDidMount = async () => {
    const obj = await getContractInstance();
    this.setState({ web3:obj.web3, accounts:obj.accounts, contract: obj.contract});
  };
  mapRef = React.createRef();
  constructor(props){
    super(props);
    this.state = {
      subject: '',
      details: '',
      price: '',
      type:'',
      quantity: '',
      web3: null,
      accounts: null,
      contract: null,
      hasLocation: false,
      latlng: {
      lat: 51.505,
      lng: -0.09,
    },
      added_file_hash: null
    };

    this.handleInput = this.handleInput.bind(this);
    this.runExample = this.runExample.bind(this);
    this.captureFile = this.captureFile.bind(this);
  }

  handleClick = () => {
    const map = this.mapRef.current
    if (map != null) {
      map.leafletElement.locate()
    }
  }

  handleLocationFound = (e: Object) => {
    this.setState({
      hasLocation: true,
      latlng: e.latlng,
    })
  }

  handleInput(event) {
    const target = event.target;
    if (target.name == "subject"){
      this.setState(Object.assign({}, this.state, {subject: target.value}));
    }
    else if (target.name == "details") {
      this.setState(Object.assign({}, this.state, {details: target.value}));
    }
    else if (target.name == "price"){
      this.setState(Object.assign({}, this.state, {price: target.value}));
    }
    else if (target.name == "type"){
      this.setState(Object.assign({}, this.state, {type: target.value}));
    }
    else if (target.name == "quantity"){
      this.setState(Object.assign({}, this.state, {quantity: target.value}));
    }
    else {
      this.setState(Object.assign({}, this.state, {name: target.value}));
    }
  }
  render(){
    const marker = this.state.hasLocation ? (
      <Marker position={this.state.latlng}>
        <Popup>You are here</Popup>
      </Marker>
    ) : null
    return(
      <div>
        <Container className="main-container">
          <Row>
            <Col sm="12" md="12">
              <div>
                <h3>Add New Item on Marketplace</h3><hr/> <br />
                <Card>
                  <CardHeader>Enter The Details Of Yield</CardHeader>
                  <CardBody>
                    <CardTitle>Name</CardTitle>
                    <FormInput name="subject" placeholder="Name of the Item" value={this.state.subject} onChange={this.handleInput} />
                    <br />
                    <CardTitle>Details</CardTitle>
                    <FormTextarea name="details" value={this.state.details} onChange={this.handleInput} placeholder="Enter Item Details"/>
                    <br />
                      <CardTitle>Selling Price</CardTitle>
                      <FormInput name="price" value={this.state.price} onChange={this.handleInput} placeholder="Enter Item Price"/>
                      <br />
                        <CardTitle>Quantity</CardTitle>
                        <FormInput name="quantity" value={this.state.quantity} onChange={this.handleInput} placeholder="Enter Item Quantity"/>
                        <br />
                      <CardTitle>Crop Type</CardTitle>
                        <FormSelect name="type" onChange={this.handleInput}>
                          <option value="">Choose</option>
                            <option value="rabi">Rabi</option>
                            <option value="kharif">Kharif</option>
                            <option value="other">Other</option>
                          </FormSelect>
                    <CardTitle>Farm Location</CardTitle>
                    <Map
                center={this.state.latlng}
                length={4}
                onClick={this.handleClick}
                onLocationfound={this.handleLocationFound}
                ref={this.mapRef}
                zoom={13}>
                <TileLayer
                  attribution='&amp;copy <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                  url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />
                {marker}
                  </Map>
                    <br />
                    <CardTitle>Give Us Some Images</CardTitle>
                    <FormInput type="file" theme="danger" onChange={this.captureFile} placeholder="Upload an Image" className="form-control"/>
                    <br /> <br />
                    <center><Button theme="success" onClick={this.runExample}>Submit</Button></center>
                  </CardBody>
                </Card>
              </div>
            </Col>
          </Row>
        </Container>
      </div>
    );
  }
}
