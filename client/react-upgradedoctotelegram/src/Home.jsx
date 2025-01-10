import { Container, Col, Row, Button } from 'react-bootstrap'

function Home () {
    return (
        <Container fluid>
            <Row>
                <Col>
                    <Button onClick={()=>{}} variant='light' >SignUp</Button>
                </Col>
                <Col>
                    <Button onClick={()=>{}} variant='light' >Login</Button>
                </Col>
            </Row>
        </Container>
    )
}

export default Home;