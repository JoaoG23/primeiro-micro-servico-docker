const express = require('express');
const router = express.Router(); 
const ControllerGestoresSistema = require('../Controllers/ControllerGestoresSistema');

router.get("/listar", ControllerGestoresSistema.buscaRegistrados );
router.get("/:idgestor", ControllerGestoresSistema.buscaGestorId );

router.delete("/:idgestor", ControllerGestoresSistema.deleteGestor );


module.exports = router;