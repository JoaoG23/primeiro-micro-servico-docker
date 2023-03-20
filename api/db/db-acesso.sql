--
-- PostgreSQL database dump
--

-- Dumped from database version 11.15
-- Dumped by pg_dump version 11.15

-- Started on 2023-03-20 19:37:29

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 644 (class 1247 OID 16550)
-- Name: enum_direcao; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_direcao AS ENUM (
    'Entrada',
    'Saida'
);


ALTER TYPE public.enum_direcao OWNER TO postgres;

--
-- TOC entry 213 (class 1255 OID 16555)
-- Name: pr_baixa_acessos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pr_baixa_acessos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN 
			update tbcredencial_cadastradas 
			set credito_credencial = credito_credencial - 1
			 where tbcredencial_cadastradas.credencial = new.credencial_acesso;			
			return new;
	END		
$$;


ALTER FUNCTION public.pr_baixa_acessos() OWNER TO postgres;

--
-- TOC entry 214 (class 1255 OID 16556)
-- Name: pr_trig_delete_credencial(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pr_trig_delete_credencial() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		begin
			delete from tbcredencial_cadastradas where tbcredencial_cadastradas.credencial = old.crendencial_usuario;
			return OLD;
		end;
		
$$;


ALTER FUNCTION public.pr_trig_delete_credencial() OWNER TO postgres;

--
-- TOC entry 215 (class 1255 OID 16557)
-- Name: pr_update_datainicial(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pr_update_datainicial() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN 
			update tbcredencial_cadastradas set data_inicial_credencial = current_timestamp + tempo_afastamento 
			where credencial = new.credencial;
			return new;
	END		
$$;


ALTER FUNCTION public.pr_update_datainicial() OWNER TO postgres;

--
-- TOC entry 217 (class 1255 OID 16558)
-- Name: procedure_adicionar_tipo_afastamento(json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_adicionar_tipo_afastamento(entrada_dados_afastamento json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
DECLARE
	respFinal json;
		BEGIN
				
					INSERT INTO tb_tipo_afastamento
					SELECT *		
					FROM JSON_POPULATE_RECORD(NULL::tb_tipo_afastamento,$1);
					respFinal := '{"situacao":true,"msg":"Afastamento inserido com sucesso "}';
					
					RETURN respFinal;
					
			EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro na adicionar tipo *_*"}';
		END;
$_$;


ALTER FUNCTION public.procedure_adicionar_tipo_afastamento(entrada_dados_afastamento json) OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 16559)
-- Name: procedure_adicionar_tipo_afastamento(json, json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_adicionar_tipo_afastamento(entrada_dados_afastamento json, saida_resposta json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
DECLARE
		BEGIN
		
				INSERT INTO tb_tipo_afastamento
				SELECT *		
				FROM JSON_POPULATE_RECORD(NULL::tb_tipo_afastamento,$1);
-- 				respFinal := '{"situacao":true,"msg":"Afastamento inserido com sucesso "}';
				
				saida_resposta:= '{"situacao":true,"msg":"Afastamento inserido com sucesso "}';					
			EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro na adicionar tipo *_*"}';
		END;
$_$;


ALTER FUNCTION public.procedure_adicionar_tipo_afastamento(entrada_dados_afastamento json, saida_resposta json) OWNER TO postgres;

--
-- TOC entry 221 (class 1255 OID 16560)
-- Name: procedure_adicionar_usuario(json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_adicionar_usuario(data json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		if $1 <> '' then
			INSERT INTO tb_usuarios
			SELECT *		
			FROM JSON_POPULATE_RECORD(NULL::tb_usuarios,$1);
			RETURN '{"situacao":true,"msg":"Usuario inserido com sucesso :D"}';
		else
			RETURN '{"situacao":false,"msg":"Voce nao passou nada para adicionar, como quer que eu adicione algo pooh! aff! -_-"}';
		end if;
		
	EXCEPTION WHEN others THEN
		raise EXCEPTION '{"situacao":"false","msg":"Houve um erro na procedure_adicionar_usuario verifique o erro! "}';
		
	END;
$_$;


ALTER FUNCTION public.procedure_adicionar_usuario(data json) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16561)
-- Name: procedure_adicionar_usuario_credencial(json, json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_adicionar_usuario_credencial(dadoscredencial json, dadosusuario json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
DECLARE
	
		BEGIN
		
					INSERT INTO tbcredencial_cadastradas
					SELECT *		
					FROM JSON_POPULATE_RECORD(NULL::tbcredencial_cadastradas,$1);

					INSERT INTO tb_usuarios
					SELECT *		
					FROM JSON_POPULATE_RECORD(NULL::tb_usuarios,$2);
					RETURN '{"situacao":true,"msg":"Usuario inserido com sucesso"}';

		END;
$_$;


ALTER FUNCTION public.procedure_adicionar_usuario_credencial(dadoscredencial json, dadosusuario json) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16562)
-- Name: procedure_atualizar_afastamento(character varying, character varying, interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_atualizar_afastamento(id_afast character varying, entrada_nome character varying, data_acesso interval) RETURNS json
    LANGUAGE plpgsql
    AS $_$

	BEGIN
				if exists(SELECT * FROM tb_tipo_afastamento  WHERE id_afastamento = $1 ) then
					UPDATE tb_tipo_afastamento SET nome_afastamento = $2, fg_tempo_afastamento = $3 WHERE  id_afastamento = $1;
					
					RETURN '{"situacao":true,"msg":"Afastamento atualizado com sucesso"}';
				else
					RETURN '{"situacao":false,"msg":"Esse Afastamento nao existe ou o seu ID esta errado"}';

			 	end if;
	EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao": false ,"msg":"Houve um erro. Nada atualizado -_-"}';
	END;
	
$_$;


ALTER FUNCTION public.procedure_atualizar_afastamento(id_afast character varying, entrada_nome character varying, data_acesso interval) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16563)
-- Name: procedure_atualizar_usuario(character varying, json, json); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_atualizar_usuario(character varying, dados_credencial json, dados_usuario json) RETURNS json
    LANGUAGE plpgsql
    AS $_$

	BEGIN
				if exists(SELECT * FROM tb_usuarios WHERE id_usuario = $1 ) then
				
					DELETE from tb_usuarios where id_usuario = $1;
					
					INSERT INTO tbcredencial_cadastradas SELECT * FROM JSON_POPULATE_RECORD(NULL::tbcredencial_cadastradas,$2);
					INSERT INTO tb_usuarios SELECT * FROM JSON_POPULATE_RECORD(NULL::tb_usuarios,$3);
					
					RETURN '{"situacao":true,"msg":"Usuario Atualizado com sucesso"}';
				else
					RETURN '{"situacao":false,"msg":"Esse usuario nao existe ou o seu ID esta errado"}';

			 	end if;
	END;
	
$_$;


ALTER FUNCTION public.procedure_atualizar_usuario(character varying, dados_credencial json, dados_usuario json) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16564)
-- Name: procedure_busca_acesso_pela_credencial(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_acesso_pela_credencial(codigo_credencial character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		if EXISTS(SELECT * FROM tb_registro_acessos WHERE credencial_acesso = $1 ) then
		
			return (SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON(tb_registro_acessos)))
				FROM tb_registro_acessos where credencial_acesso = $1 );
		else
			RETURN '{"situacao":false, "msg":"Ou essa Credencial esta INATIVA, ou ela nao existe no sistema !"}';
		end if;

	END;
$_$;


ALTER FUNCTION public.procedure_busca_acesso_pela_credencial(codigo_credencial character varying) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16565)
-- Name: procedure_busca_acesso_pela_datahora(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_acesso_pela_datahora(data_inicial timestamp without time zone, data_final timestamp without time zone) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		IF EXISTS( SELECT data_acesso FROM tb_registro_acessos WHERE data_acesso between  $1 and $2 ) then
		
			return (SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON(tb_registro_acessos)))
				FROM tb_registro_acessos where data_acesso between $1 and $2 );
		else
			return '{"situacao":false ,"msg":"Não nenhum registro entre esse periodos! Por favor, coloque onde contem registros"}';
		end if;
		

	END;
$_$;


ALTER FUNCTION public.procedure_busca_acesso_pela_datahora(data_inicial timestamp without time zone, data_final timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 216 (class 1255 OID 16566)
-- Name: procedure_busca_afastamento_pelo_id(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_afastamento_pelo_id(id_afastamento_entrada character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		if EXISTS(SELECT * FROM tb_tipo_afastamento WHERE id_afastamento = $1 ) then
		
			RETURN(SELECT (ROW_TO_JSON(tb_tipo_afastamento))
			FROM tb_tipo_afastamento where id_afastamento = $1);
		else
			RETURN '{"situacao":false, "msg":"Ou seu ID e vazio, ou ele nao existe no Sistema! "}';
		end if;

	END;
$_$;


ALTER FUNCTION public.procedure_busca_afastamento_pelo_id(id_afastamento_entrada character varying) OWNER TO postgres;

--
-- TOC entry 218 (class 1255 OID 16567)
-- Name: procedure_busca_gestor(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_gestor() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN

		RETURN(SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON( tb_registrar_gestor )))
		FROM tb_registrar_gestor);

			EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro na procedure_busca_usuario *_*"}';
	END;
$$;


ALTER FUNCTION public.procedure_busca_gestor() OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 16711)
-- Name: procedure_busca_gestor_login(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_gestor_login(login_nome character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		if EXISTS(SELECT * FROM tb_registrar_gestor WHERE login_gestor = $1 ) then
		
			RETURN(SELECT (ROW_TO_JSON(tb_registrar_gestor))
			FROM tb_registrar_gestor where login_gestor = $1);
		else
			RETURN '{"situacao":false, "msg":"Ou seu Login e vazio, ou ele nao existe no Sistema! "}';
		end if;

	END;
$_$;


ALTER FUNCTION public.procedure_busca_gestor_login(login_nome character varying) OWNER TO postgres;

--
-- TOC entry 220 (class 1255 OID 16568)
-- Name: procedure_busca_gestor_pelo_id(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_gestor_pelo_id(id_entrada integer) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		if EXISTS(SELECT * FROM tb_registrar_gestor WHERE id_gestor = $1 ) then
		
			RETURN(SELECT (ROW_TO_JSON(tb_registrar_gestor))
			FROM tb_registrar_gestor where id_gestor = $1);
		else
			RETURN '{"situacao":false, "msg":"Ou seu ID e vazio, ou ele nao existe no Sistema! "}';
		end if;

	END;
$_$;


ALTER FUNCTION public.procedure_busca_gestor_pelo_id(id_entrada integer) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16569)
-- Name: procedure_busca_relatorio_pela_datahora(character varying, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_relatorio_pela_datahora(credencial_entrada character varying, data_inicial timestamp without time zone, data_final timestamp without time zone) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	------ Verifica se existe 
		IF EXISTS( SELECT credencial_relatorio FROM tb_relatorios_acessos
				  WHERE credencial_relatorio = credencial_entrada ) THEN
		----- Filtro com credencial expecifica 
			IF EXISTS ( SELECT credencial_relatorio FROM tb_relatorios_acessos where data_acesso_relatorio BETWEEN $2 and $3 and credencial_relatorio = $1) THEN
					   
					RETURN (SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON( tb_relatorios_acessos ))) FROM tb_relatorios_acessos where data_acesso_relatorio between $2 and $3 and credencial_relatorio = $1);
			ELSE 
					RETURN (SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON( tb_relatorios_acessos ))) FROM tb_relatorios_acessos where data_acesso_relatorio between $2 and $3 );
			END IF;
		ELSE
			RETURN (SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON( tb_relatorios_acessos ))) FROM tb_relatorios_acessos where data_acesso_relatorio between $2 and $3 ); 
		END IF;
		
		EXCEPTION WHEN others THEN
		raise EXCEPTION '{situacao:"false","msg":"Houve um erro na procedure_busca_relatorio_pela_datahora verifique o erro! "}';
		
	END;
$_$;


ALTER FUNCTION public.procedure_busca_relatorio_pela_datahora(credencial_entrada character varying, data_inicial timestamp without time zone, data_final timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 16570)
-- Name: procedure_busca_tipos_afastamentos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_tipos_afastamentos() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN

		RETURN(SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(tb_tipo_afastamento)))
		FROM tb_tipo_afastamento);

			EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro na procedure_busca_usuario *_*"}';
	END;
$$;


ALTER FUNCTION public.procedure_busca_tipos_afastamentos() OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 16727)
-- Name: procedure_busca_ultimo_4meses(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_ultimo_4meses(OUT resposta json) RETURNS json
    LANGUAGE plpgsql
    AS $$

DECLARE
	contagem30Dias bigint;
	contagem60Dias bigint;
	contagem90Dias bigint;
	contagem120Dias bigint;
	BEGIN
	
	contagem30Dias := (select count(data_acesso) from tb_registro_acessos 
		where data_acesso between now() -  interval '30 Days'  and now());
		
		contagem60Dias := (select count(data_acesso) from tb_registro_acessos 
		where data_acesso between now() -  interval '60 Days'  and now() - interval '30 Days');
		
		contagem90Dias := (select count(data_acesso) from tb_registro_acessos 
		where data_acesso between now() -  interval '90 Days'  and now() - interval '60 Days');
			
		contagem120Dias := (select count(data_acesso) from tb_registro_acessos 
		where data_acesso between now() -  interval '120 Days'  and now() - interval '90 Days');
	
		
     resposta := '{ "ultimos30Dias":'|| contagem30Dias ||', "ultimos60Dias": '|| contagem60Dias ||', "ultimos90Dias": '|| contagem90Dias ||',"ultimos120Dias": '|| contagem120Dias ||' }';

	END;
$$;


ALTER FUNCTION public.procedure_busca_ultimo_4meses(OUT resposta json) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 16718)
-- Name: procedure_busca_ultimo_acesso(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_ultimo_acesso() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
		
			RETURN(SELECT (ROW_TO_JSON(tb_registro_acessos))
			FROM tb_registro_acessos order by id_acesso desc limit 1);

	END;
$$;


ALTER FUNCTION public.procedure_busca_ultimo_acesso() OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 16725)
-- Name: procedure_busca_ultimo_periodo(interval, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_ultimo_periodo(numeroperiodo interval, situacaoacesso character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
		
RETURN ( select count(situacao_do_acesso) from tb_registro_acessos where data_acesso between now() -  numeroPeriodo  and now() and situacao_do_acesso like situacaoAcesso );

	END;
$$;


ALTER FUNCTION public.procedure_busca_ultimo_periodo(numeroperiodo interval, situacaoacesso character varying) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16571)
-- Name: procedure_busca_usuario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_usuario() RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN

		RETURN(SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON(VW_DADOS_USUARIO_CREDENCIADO)))
		FROM VW_DADOS_USUARIO_CREDENCIADO);

			EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro na procedure_busca_usuario *_*"}';
	END;
$$;


ALTER FUNCTION public.procedure_busca_usuario() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 196 (class 1259 OID 16572)
-- Name: tb_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_usuarios (
    id_usuario character varying(40) NOT NULL,
    foto_usuario text DEFAULT ''::text,
    nome_usuario character varying(100) NOT NULL,
    sobrenome_usuario character varying(80) NOT NULL,
    tipo_documento_usuario character varying(30) NOT NULL,
    numero_documento_usuario character varying(20) NOT NULL,
    telefone_usuario character varying(15) DEFAULT ''::character varying,
    email_usuario character varying(80) DEFAULT ''::character varying,
    empresa_usuario character varying(80) DEFAULT ''::character varying,
    tipo_usuario character varying(70) DEFAULT ''::character varying,
    setor_usuario character varying(60) DEFAULT ''::character varying,
    pais_usuario character varying(80) DEFAULT 'Brasil'::character varying,
    estado_usuario character varying(70) DEFAULT 'Minas Gerais'::character varying,
    cidade_usuario character varying(60) DEFAULT 'Belo horizonte'::character varying,
    rua_usuario character varying(80) DEFAULT ''::character varying,
    numero_usuario character varying(6) DEFAULT ''::character varying,
    crendencial_usuario character varying(50) NOT NULL
);


ALTER TABLE public.tb_usuarios OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16589)
-- Name: tbcredencial_cadastradas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbcredencial_cadastradas (
    id_credencial character varying(40) NOT NULL,
    situacao_credencial character varying(15) NOT NULL,
    data_inicial_credencial timestamp without time zone NOT NULL,
    data_final_credencial timestamp without time zone NOT NULL,
    direcao public.enum_direcao DEFAULT 'Entrada'::public.enum_direcao,
    credencial character varying(50) NOT NULL,
    credito_credencial integer DEFAULT 2 NOT NULL,
    tempo_afastamento interval DEFAULT '00:00:00'::interval NOT NULL
);


ALTER TABLE public.tbcredencial_cadastradas OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 16595)
-- Name: vw_dados_usuario_paginacao; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_dados_usuario_paginacao AS
 SELECT u.id_usuario,
    u.nome_usuario,
    u.sobrenome_usuario,
    cr.credencial,
    cr.situacao_credencial,
    cr.data_final_credencial,
    cr.credito_credencial,
    u.email_usuario
   FROM (public.tb_usuarios u
     LEFT JOIN public.tbcredencial_cadastradas cr ON (((u.crendencial_usuario)::text = (cr.credencial)::text)));


ALTER TABLE public.vw_dados_usuario_paginacao OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16599)
-- Name: procedure_busca_usuario_paginacao(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_usuario_paginacao(numero_pagina integer, quantidade_dados integer) RETURNS SETOF public.vw_dados_usuario_paginacao
    LANGUAGE plpgsql
    AS $_$
BEGIN
	RETURN QUERY SELECT * FROM vw_dados_usuario_paginacao offset ($1 - 1) * $2 limit $2;
	RETURN;
END;
$_$;


ALTER FUNCTION public.procedure_busca_usuario_paginacao(numero_pagina integer, quantidade_dados integer) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16600)
-- Name: procedure_busca_usuario_pelo_id(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_usuario_pelo_id(id_do_usuario character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		if EXISTS(SELECT * FROM vw_todos_dados_usuario_credenciado WHERE id_usuario = $1 ) then
		
			RETURN(SELECT (ROW_TO_JSON(vw_todos_dados_usuario_credenciado))
			FROM vw_todos_dados_usuario_credenciado where id_usuario = $1);
		else
			RETURN '{"situacao":false, "msg":"Ou seu ID e vazio, ou ele nao existe no Sistema! "}';
		end if;

	END;
$_$;


ALTER FUNCTION public.procedure_busca_usuario_pelo_id(id_do_usuario character varying) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 16710)
-- Name: procedure_busca_usuario_pelo_nome(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_busca_usuario_pelo_nome(nome character varying) RETURNS SETOF public.vw_dados_usuario_paginacao
    LANGUAGE plpgsql
    AS $_$
    BEGIN
	RETURN QUERY
        SELECT * FROM vw_dados_usuario_paginacao where nome_usuario = $1 or sobrenome_usuario = $1;
    END;
$_$;


ALTER FUNCTION public.procedure_busca_usuario_pelo_nome(nome character varying) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16601)
-- Name: procedure_deletar_afastamento(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_deletar_afastamento(entrada_dados_afastamento character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
DECLARE
	
		BEGIN
				if exists (SELECT * FROM tb_tipo_afastamento WHERE id_afastamento = $1 ) then
					delete from tb_tipo_afastamento where id_afastamento = $1;

					RETURN '{"situacao":true,"msg":"Afastamento DELETADO com sucesso"}';
				else
					RETURN '{"situacao":false,"msg":"Woooooh! esse afastamento nao existe"}';
				end if;
			EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro na deletar o afastamento *_*"}';
		END;
$_$;


ALTER FUNCTION public.procedure_deletar_afastamento(entrada_dados_afastamento character varying) OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 16602)
-- Name: procedure_deletar_gestor(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_deletar_gestor(entrada_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN 
		IF EXISTS (select * from tb_registrar_gestor where id_gestor = $1) THEN
				delete from tb_registrar_gestor where id_gestor = $1;
				RETURN '{"situacao":true ,"msg":"Usuario deletado com sucesso"}';
			ELSE
				RETURN '{"situacao":false ,"msg":"Esse usuario nao existe para ser deletado"}';
		END IF;
		
		EXCEPTION WHEN others THEN 
			RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro no banco de dados *_*"}';
	END;
	

	
$_$;


ALTER FUNCTION public.procedure_deletar_gestor(entrada_id integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 16746)
-- Name: procedure_email_atualizar_dados(character varying, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_email_atualizar_dados(host character varying, port integer, usuario character varying, senha character varying, ssl_tls character varying DEFAULT ''::character varying, OUT feedback json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
BEGIN 
	update tb_email_config 
	set host_email = $1,
	port_email = $2,
	usuario_email = $3,
	senha_email = $4,
	config_ssl_tls = $5
	where id_email_config = 1;
	
	feedback := '{"situacao":true ,"msg":"Configurações de email salvadas com sucesso."}';
	
	EXCEPTION WHEN others THEN
		RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro no procedimento de salvamento de configurações da email "}';
END;
$_$;


ALTER FUNCTION public.procedure_email_atualizar_dados(host character varying, port integer, usuario character varying, senha character varying, ssl_tls character varying, OUT feedback json) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 16740)
-- Name: procedure_email_busca(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_email_busca() RETURNS json
    LANGUAGE plpgsql
    AS $$
BEGIN 
RETURN(SELECT ROW_TO_JSON( tb_email_config )
		FROM tb_email_config );
END;
$$;


ALTER FUNCTION public.procedure_email_busca() OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 16603)
-- Name: procedure_registrar_gestor(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_registrar_gestor(login character varying, senha character varying, email character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN 
		IF EXISTS (select email_gestor from tb_registrar_gestor where email_gestor = email) THEN
			INSERT INTO TB_REGISTRAR_GESTOR values (default, login , senha , email);

				RETURN '{"situacao":false ,"msg":"Esse email ou senha ja em uso"}';
			ELSE
				begin
					if exists (select login_gestor from tb_registrar_gestor where login_gestor = login and senha_gestor = senha) then 
						return '{"situacao":false ,"msg":"Ou usuario ou senha já existem! Tente outro por gentileza"}';
					else
						INSERT INTO TB_REGISTRAR_GESTOR values (default, login , senha , email);
						RETURN '{"situacao":true ,"msg":"Gestor cadastrado com sucesso :D"}';
					end if;
				end;

		END IF;
		
	END;
	

	
$$;


ALTER FUNCTION public.procedure_registrar_gestor(login character varying, senha character varying, email character varying) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 16604)
-- Name: procedure_relatorios_todos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_relatorios_todos() RETURNS json
    LANGUAGE plpgsql
    AS $$
		BEGIN
				return (SELECT ARRAY_TO_JSON (ARRAY_AGG(ROW_TO_JSON(tb_relatorios_acessos)))
				FROM tb_relatorios_acessos );

			EXCEPTION WHEN others THEN 
				RAISE EXCEPTION '{"situacao":false,"msg":"Houve um erro procedure_todos_acessos *_*"}';
		END;
	
$$;


ALTER FUNCTION public.procedure_relatorios_todos() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 16605)
-- Name: procedure_remover_usuario(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_remover_usuario(character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		if exists (SELECT * FROM tb_usuarios WHERE id_usuario = $1 ) then
			delete from tb_usuarios where id_usuario = $1;
			RETURN '{"situacao":true, "msg":"Usuario removido com sucesso"}';
		else 
			RETURN '{"situacao":false ,"msg":"Ou voce passou paramentros vazio ou a credencial nao existe!"}';
		end if;
	EXCEPTION WHEN others THEN 
		RAISE EXCEPTION '{"situacao": false ,"msg":"Houve um erro. Nada atualizado -_-"}';
	END;
$_$;


ALTER FUNCTION public.procedure_remover_usuario(character varying) OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 16606)
-- Name: procedure_remover_usuario_credencial(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_remover_usuario_credencial(character varying, character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	
		if $1 <> '' and $2 <> '' then
			delete from tb_usuarios where id_usuario = $1;
			delete from tbcredencial_cadastradas where credencial = $2;
			RETURN '{"situacao":"true","msg":"Usuario removido com sucesso"}';
		else
			RETURN '{"situacao":"false","msg":"Usuario nao foi removido"}';
		end if;
		
		EXCEPTION WHEN others THEN 
		RAISE EXCEPTION '{"situacao":"false","msg":"Houve um erro. Nada Removido -_-"}';
	END;
$_$;


ALTER FUNCTION public.procedure_remover_usuario_credencial(character varying, character varying) OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16617)
-- Name: tb_registro_acessos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_registro_acessos (
    id_acesso integer NOT NULL,
    situacao_do_acesso character varying(60) DEFAULT ''::character varying,
    nome_acesso character varying(100) DEFAULT ''::character varying,
    sobrenome_acesso character varying(70) DEFAULT ''::character varying,
    tipo_documento_usuario character varying(30) DEFAULT ''::character varying,
    numero_documento_usuario character varying(20) DEFAULT ''::character varying,
    credencial_acesso character varying(50) DEFAULT ''::character varying,
    situacao_credencial character varying(15) DEFAULT ''::character varying,
    direcao character varying(10) DEFAULT ''::character varying,
    data_acesso timestamp without time zone DEFAULT now(),
    data_final_credencial timestamp without time zone DEFAULT now(),
    restam_acessos integer DEFAULT 0,
    situacao_afastamento character varying(50) DEFAULT 'Sem afastamento'::character varying NOT NULL
);


ALTER TABLE public.tb_registro_acessos OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 16717)
-- Name: procedure_todos_acessos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_todos_acessos() RETURNS SETOF public.tb_registro_acessos
    LANGUAGE plpgsql
    AS $$
		BEGIN
			RETURN QUERY
        	SELECT * FROM tb_registro_acessos order by id_acesso desc limit 11;
		END;
$$;


ALTER FUNCTION public.procedure_todos_acessos() OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 16730)
-- Name: procedure_todos_registros_ultimo_30_dias(interval); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_todos_registros_ultimo_30_dias(numeroperiodo interval) RETURNS json
    LANGUAGE plpgsql
    AS $$
	BEGIN
		
RETURN ( select count(situacao_do_acesso) from tb_registro_acessos where data_acesso between now() -  numeroPeriodo  and now() );

	END;
$$;


ALTER FUNCTION public.procedure_todos_registros_ultimo_30_dias(numeroperiodo interval) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 16608)
-- Name: procedure_valida_login(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_valida_login(login character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN
	
		if exists ( select * from tb_registrar_gestor where login_gestor = $1 ) then
		
		 	RETURN
			(SELECT (ROW_TO_JSON(tb_registrar_gestor)) FROM tb_registrar_gestor where login_gestor = $1);
		else
			RETURN '{"situacao":false ,"msg":"Erro: Ou senha ou login estao incorretos"}';
		end if;
		

	
	END;

$_$;


ALTER FUNCTION public.procedure_valida_login(login character varying) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16609)
-- Name: procedure_verifica_se_existe_credencial(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.procedure_verifica_se_existe_credencial(entrada_credencial character varying, entrada_direcao character varying) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	DECLARE fuc_inserer_dados text;
	begin
	
		
	-- 1º passo - Verifica se existe a credencial na tabela
		 IF EXISTS( SELECT credencial FROM tbcredencial_cadastradas WHERE credencial = $1 and credito_credencial > 0 )  THEN
		 
		 	-- 2º passo - Verifica Validade 
			IF EXISTS( SELECT credencial FROM tbcredencial_cadastradas WHERE data_inicial_credencial < current_timestamp and data_final_credencial > current_timestamp and credencial = $1 ) THEN
					  
				-- Acesso Liberado 	  
				PERFORM subprocedure_inserer_dados_acesso($1, 'ACESSO LIBERADO', $2);
				-- Relatorio
				PERFORM subprocedure_inserer_dados_relatorio($1);
				
				return '{"acesso":true,"permissao":true,"credencial":"valida","msg":"Credencial Permitida pode passar"}'::json;
			ELSE
			
			--- Acesso negado Crendecial vencida -----
				
				PERFORM subprocedure_inserer_dados_acesso($1, 'ACESSO NEGADO: Credencial vencida ou inativa', $2);
				-- Relatorio
				PERFORM subprocedure_inserer_dados_relatorio($1);
				return '{"acesso":false, "permissao":true, "credencial":"inativa", "msg":"Credencial vencida ou inativa no momento! Por favor verifique com responsavel o ocorrido!"}'::json;

			END IF;
		ELSE
			-------Insere dado invalido e acesso Barrado -----
			Insert into tb_registro_acessos (
											situacao_do_acesso,
											nome_acesso,
											 sobrenome_acesso,
											 credencial_acesso,
											 situacao_credencial,
											 direcao,
											 data_final_credencial,
											 restam_acessos
											)
											 values
											 ('ACESSO BARRADO','Credencial Inexistente ou Sem Creditos','',$1,'INVALIDA',$2,current_timestamp,0);
				return '{"acesso":false, "permissao":true, "credencial":"invalida","msg":"Essa credencial esta invalida ou inexistente! Por gentileza cadastre-se no sistema Joao Acesso! "}'::json;
			

				-- Relatorio
				PERFORM subprocedure_inserer_dados_relatorio($1);
			END IF;
		END;

$_$;


ALTER FUNCTION public.procedure_verifica_se_existe_credencial(entrada_credencial character varying, entrada_direcao character varying) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 16610)
-- Name: subprocedure_inserer_dados_acesso(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.subprocedure_inserer_dados_acesso(credencial_entrada character varying, situacao_acesso_entrada character varying, OUT saida json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN

	 		INSERT INTO tb_registro_acessos (
					 situacao_do_acesso,
					nome_acesso,
					sobrenome_acesso,
					credencial_acesso,
					situacao_credencial,
					data_final_credencial,
					direcao,
					restam_acessos,
					situacao_afastamento
				 )

				SELECT 
				$2,
				nome_usuario,
				sobrenome_usuario,
				crendencial_usuario,
				situacao_credencial,
				data_final_credencial ,
				direcao ,
				credito_credencial,
				nome_afastamento
				
				FROM vw_todos_dados_usuario_credenciado where crendencial_usuario = $1;
				
			
			 	saida := '{"situacao":true ,"msg":"inserido com sucesso"}';
			
	EXCEPTION WHEN others THEN
		RAISE EXCEPTION '{"situacao":"false","msg":"Houve um erro na funcao fuc_inserer_usuarioecredencial verifique o erro! "}';
	END;
$_$;


ALTER FUNCTION public.subprocedure_inserer_dados_acesso(credencial_entrada character varying, situacao_acesso_entrada character varying, OUT saida json) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 16719)
-- Name: subprocedure_inserer_dados_acesso(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.subprocedure_inserer_dados_acesso(credencial_entrada character varying, situacao_acesso_entrada character varying, direcao_entrada character varying, OUT saida json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN

	 		INSERT INTO tb_registro_acessos (
					 situacao_do_acesso,
					nome_acesso,
					sobrenome_acesso,
					credencial_acesso,
					situacao_credencial,
					data_final_credencial,
					direcao,
					restam_acessos,
					situacao_afastamento
				 )

				SELECT 
				$2,
				nome_usuario,
				sobrenome_usuario,
				crendencial_usuario,
				situacao_credencial,
				data_final_credencial ,
				$3,
				credito_credencial,
				nome_afastamento
				
				FROM vw_todos_dados_usuario_credenciado where crendencial_usuario = $1;
				
			
			 	saida := '{"situacao":true ,"msg":"inserido com sucesso"}';
			
	EXCEPTION WHEN others THEN
		RAISE EXCEPTION '{"situacao":"false","msg":"Houve um erro na funcao fuc_inserer_usuarioecredencial verifique o erro! "}';
	END;
$_$;


ALTER FUNCTION public.subprocedure_inserer_dados_acesso(credencial_entrada character varying, situacao_acesso_entrada character varying, direcao_entrada character varying, OUT saida json) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16611)
-- Name: subprocedure_inserer_dados_relatorio(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.subprocedure_inserer_dados_relatorio(credencial_entrada character varying, OUT saida json) RETURNS json
    LANGUAGE plpgsql
    AS $_$
	BEGIN

	 insert into tb_relatorios_acessos (
		 
			  acesso_relatorio,
		 nome_relatorio,
		 sobrenome_relatorio,
		 tipo_documento_relatorio,
		 numero_documento_relatorio,
		 credencial_relatorio,
		 situacao_credencial_relatorio,
		 direcao_relatorio,
		 data_acesso_relatorio,
		 data_final_relatorio,
		 restam_acessos_relatorio,
		 situacao_afastamento_relatorio
		 
			 ) SELECT situacao_do_acesso, nome_acesso, sobrenome_acesso, tipo_documento_usuario, numero_documento_usuario, credencial_acesso, situacao_credencial, direcao, data_acesso, data_final_credencial, restam_acessos, situacao_afastamento
			FROM tb_registro_acessos where credencial_acesso = $1 order by id_acesso desc limit 1;
				
			
			 	saida := '{"situacao":true ,"msg":"inserido com sucesso"}';
			
	EXCEPTION WHEN others THEN
		RAISE EXCEPTION '{"situacao":"false","msg":"Houve um erro na funcao fuc_inserer_usuarioecredencial verifique o erro! "}';
	END;
$_$;


ALTER FUNCTION public.subprocedure_inserer_dados_relatorio(credencial_entrada character varying, OUT saida json) OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16736)
-- Name: tb_email_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_email_config (
    id_email_config integer NOT NULL,
    host_email character varying(100),
    port_email integer,
    usuario_email character varying(90),
    senha_email character varying(80),
    config_ssl_tls character varying(40)
);


ALTER TABLE public.tb_email_config OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16734)
-- Name: tb_email_config_id_email_config_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_email_config_id_email_config_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_email_config_id_email_config_seq OWNER TO postgres;

--
-- TOC entry 2988 (class 0 OID 0)
-- Dependencies: 211
-- Name: tb_email_config_id_email_config_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_email_config_id_email_config_seq OWNED BY public.tb_email_config.id_email_config;


--
-- TOC entry 199 (class 1259 OID 16612)
-- Name: tb_registrar_gestor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_registrar_gestor (
    id_gestor integer NOT NULL,
    login_gestor character varying(100) NOT NULL,
    senha_gestor character varying(300) NOT NULL,
    email_gestor character varying(70) NOT NULL
);


ALTER TABLE public.tb_registrar_gestor OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 16615)
-- Name: tb_registrar_gestor_id_gestor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_registrar_gestor_id_gestor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_registrar_gestor_id_gestor_seq OWNER TO postgres;

--
-- TOC entry 2989 (class 0 OID 0)
-- Dependencies: 200
-- Name: tb_registrar_gestor_id_gestor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_registrar_gestor_id_gestor_seq OWNED BY public.tb_registrar_gestor.id_gestor;


--
-- TOC entry 202 (class 1259 OID 16632)
-- Name: tb_registro_acessos_id_acesso_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_registro_acessos_id_acesso_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_registro_acessos_id_acesso_seq OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 16634)
-- Name: tb_registro_acessos_id_acesso_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_registro_acessos_id_acesso_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_registro_acessos_id_acesso_seq1 OWNER TO postgres;

--
-- TOC entry 2990 (class 0 OID 0)
-- Dependencies: 203
-- Name: tb_registro_acessos_id_acesso_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_registro_acessos_id_acesso_seq1 OWNED BY public.tb_registro_acessos.id_acesso;


--
-- TOC entry 204 (class 1259 OID 16636)
-- Name: tb_relatorios_acessos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_relatorios_acessos (
    id_relatorio integer NOT NULL,
    acesso_relatorio character varying(60) DEFAULT ''::character varying,
    nome_relatorio character varying(100) DEFAULT ''::character varying,
    sobrenome_relatorio character varying(70) DEFAULT ''::character varying,
    tipo_documento_relatorio character varying(30) DEFAULT ''::character varying,
    numero_documento_relatorio character varying(20) DEFAULT ''::character varying,
    credencial_relatorio character varying(50) DEFAULT ''::character varying,
    situacao_credencial_relatorio character varying(15) DEFAULT ''::character varying,
    direcao_relatorio character varying(10) DEFAULT ''::character varying,
    data_acesso_relatorio timestamp without time zone DEFAULT now(),
    data_final_relatorio timestamp without time zone DEFAULT now(),
    restam_acessos_relatorio integer DEFAULT 0,
    situacao_afastamento_relatorio character varying(50) DEFAULT 'Sem afastamento'::character varying NOT NULL
);


ALTER TABLE public.tb_relatorios_acessos OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 16651)
-- Name: tb_relatorios_acessos_id_relatorio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_relatorios_acessos_id_relatorio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_relatorios_acessos_id_relatorio_seq OWNER TO postgres;

--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 205
-- Name: tb_relatorios_acessos_id_relatorio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_relatorios_acessos_id_relatorio_seq OWNED BY public.tb_relatorios_acessos.id_relatorio;


--
-- TOC entry 206 (class 1259 OID 16653)
-- Name: tb_tipo_afastamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_tipo_afastamento (
    id_afastamento character varying(30),
    nome_afastamento character varying(50) NOT NULL,
    fg_tempo_afastamento interval DEFAULT '00:00:00'::interval NOT NULL
);


ALTER TABLE public.tb_tipo_afastamento OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 16657)
-- Name: tb_usuarios_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_usuarios_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tb_usuarios_id_usuario_seq OWNER TO postgres;

--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_usuarios_id_usuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_usuarios_id_usuario_seq OWNED BY public.tb_usuarios.id_usuario;


--
-- TOC entry 208 (class 1259 OID 16659)
-- Name: tbcredencial_cadastradas_id_credencial_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbcredencial_cadastradas_id_credencial_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbcredencial_cadastradas_id_credencial_seq OWNER TO postgres;

--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 208
-- Name: tbcredencial_cadastradas_id_credencial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbcredencial_cadastradas_id_credencial_seq OWNED BY public.tbcredencial_cadastradas.id_credencial;


--
-- TOC entry 209 (class 1259 OID 16661)
-- Name: vw_dados_usuario_credenciado; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_dados_usuario_credenciado AS
 SELECT u.id_usuario,
    u.foto_usuario,
    u.nome_usuario,
    u.sobrenome_usuario,
    u.tipo_documento_usuario,
    u.numero_documento_usuario,
    cr.credencial,
    cr.situacao_credencial,
    cr.data_inicial_credencial,
    cr.data_final_credencial,
    cr.direcao,
    cr.credito_credencial
   FROM (public.tb_usuarios u
     LEFT JOIN public.tbcredencial_cadastradas cr ON (((u.crendencial_usuario)::text = (cr.credencial)::text)));


ALTER TABLE public.vw_dados_usuario_credenciado OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16666)
-- Name: vw_todos_dados_usuario_credenciado; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_todos_dados_usuario_credenciado AS
 SELECT us.id_usuario,
    us.foto_usuario,
    us.nome_usuario,
    us.sobrenome_usuario,
    us.tipo_documento_usuario,
    us.numero_documento_usuario,
    us.telefone_usuario,
    us.email_usuario,
    us.empresa_usuario,
    us.tipo_usuario,
    us.setor_usuario,
    us.pais_usuario,
    us.estado_usuario,
    us.cidade_usuario,
    us.rua_usuario,
    us.numero_usuario,
    us.crendencial_usuario,
    crd.id_credencial,
    crd.situacao_credencial,
    crd.data_inicial_credencial,
    crd.data_final_credencial,
    crd.direcao,
    crd.credito_credencial,
    af.id_afastamento,
    af.nome_afastamento,
    af.fg_tempo_afastamento
   FROM ((public.tb_usuarios us
     JOIN public.tbcredencial_cadastradas crd ON (((crd.credencial)::text = (us.crendencial_usuario)::text)))
     JOIN public.tb_tipo_afastamento af ON ((af.fg_tempo_afastamento = crd.tempo_afastamento)));


ALTER TABLE public.vw_todos_dados_usuario_credenciado OWNER TO postgres;

--
-- TOC entry 2818 (class 2604 OID 16739)
-- Name: tb_email_config id_email_config; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_email_config ALTER COLUMN id_email_config SET DEFAULT nextval('public.tb_email_config_id_email_config_seq'::regclass);


--
-- TOC entry 2790 (class 2604 OID 16671)
-- Name: tb_registrar_gestor id_gestor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_registrar_gestor ALTER COLUMN id_gestor SET DEFAULT nextval('public.tb_registrar_gestor_id_gestor_seq'::regclass);


--
-- TOC entry 2803 (class 2604 OID 16672)
-- Name: tb_registro_acessos id_acesso; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_registro_acessos ALTER COLUMN id_acesso SET DEFAULT nextval('public.tb_registro_acessos_id_acesso_seq1'::regclass);


--
-- TOC entry 2816 (class 2604 OID 16673)
-- Name: tb_relatorios_acessos id_relatorio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_relatorios_acessos ALTER COLUMN id_relatorio SET DEFAULT nextval('public.tb_relatorios_acessos_id_relatorio_seq'::regclass);


--
-- TOC entry 2982 (class 0 OID 16736)
-- Dependencies: 212
-- Data for Name: tb_email_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_email_config (id_email_config, host_email, port_email, usuario_email, senha_email, config_ssl_tls) FROM stdin;
1	smtp.office365.com	587	joaoguilherme94@live.com	34563217	
\.


--
-- TOC entry 2971 (class 0 OID 16612)
-- Dependencies: 199
-- Data for Name: tb_registrar_gestor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_registrar_gestor (id_gestor, login_gestor, senha_gestor, email_gestor) FROM stdin;
57	carlos	$2a$10$1sItF/J.kACiFaJDW6cfou/RT1i50o9gGLnLTGzvH0MXYzVZCUPxa	carlos
58	anaPortaria	$2a$10$05P6owEaKEYp8v1YPs9bxuQ0qsWn5.twlHZP02dcInLqnjLbkLMgq	anaPortaria
59	luciaRH	$2a$10$qfNghmlQC2niLlLkS7.f6.eUq.a6DwM892BAEG.OA5k1OHWxvbpRy	luciaRH
60	claudinhaExpedicao	$2a$10$RdJ9xL6zVr96tHk7QbYfTO1/Mk3cbl.W.LEGISul/uGFG8zsqwg5G	claudinhaExpedicao
63	aurentina	$2a$10$RlPHofk6BKYthnKktKhy.uBBGCQNLocxiZVdi3jDYofigL1oSA8iW	aurentina@email.com
74	admin	$2a$10$aSiZtW8zTJqyoh.7.X7TIeVhGV.LyUYjQurfEeIW/YR1ssvC/GVQG	operacaodev@gmail.com
80	joaodev	$2a$10$ap0jRryWl0phQMajTm48OeryV2lCdQpLec4/ap2o1rN7t83mrIibe	joaoguilherme94@live.com
\.


--
-- TOC entry 2973 (class 0 OID 16617)
-- Dependencies: 201
-- Data for Name: tb_registro_acessos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_registro_acessos (id_acesso, situacao_do_acesso, nome_acesso, sobrenome_acesso, tipo_documento_usuario, numero_documento_usuario, credencial_acesso, situacao_credencial, direcao, data_acesso, data_final_credencial, restam_acessos, situacao_afastamento) FROM stdin;
1	situacao_do_acesso	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-04-01 21:35:15.607092	2024-03-19 00:00:00	199	Viagem de Negocios
2	ACESSO NEGADO por Credencial vencida ou invalida	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-04-01 21:37:58.859717	2024-03-19 00:00:00	198	Viagem de Negocios
3	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-04-01 21:42:47.1216	2027-08-20 00:00:00	620	Sem afastamento 
4	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-04-01 21:42:54.753774	2027-08-20 00:00:00	619	Sem afastamento 
5	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				3	INVALIDA	Saida	2022-04-01 21:43:02.859546	2022-04-01 21:43:02.859546	0	Sem afastamento
6	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				556545SSDF	INVALIDA	Saida	2022-04-01 21:49:18.986914	2022-04-01 21:49:18.986914	0	Sem afastamento
7	ACESSO NEGADO por Credencial vencida ou invalida	Salomao	Quake			THBSHI995A	ATIVA	Entrada	2022-04-01 21:49:27.300591	2025-08-20 00:00:00	1013	Inatividade por Servicos Exteriores
8	ACESSO LIBERADO	Cleopatra	do Egito			15BB69DA	ATIVA	Entrada	2022-04-01 21:49:45.569274	2025-08-20 00:00:00	28	Sem afastamento 
9	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-04-01 21:55:34.17551	2027-08-20 00:00:00	500	Sem afastamento 
10	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-04-01 21:55:57.894085	2027-08-20 00:00:00	499	Sem afastamento 
11	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-04-01 21:56:23.217339	2027-08-20 00:00:00	500	Sem afastamento 
12	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-04-01 21:56:34.240814	2027-08-20 00:00:00	500	Sem afastamento 
13	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-04-01 21:56:39.366509	2027-08-20 00:00:00	499	Sem afastamento 
14	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-01 21:57:07.806458	2027-08-20 00:00:00	6100	Sem afastamento 
15	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-01 21:57:13.881812	2027-08-20 00:00:00	6099	Sem afastamento 
18	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-04-01 22:27:23.133749	2027-08-20 00:00:00	498	Sem afastamento 
19	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 06:57:48.385847	2027-08-20 00:00:00	6098	Sem afastamento 
20	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 08:10:39.097114	2027-08-20 00:00:00	6097	Sem afastamento 
21	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				Salomao	INVALIDA	Entrada	2022-04-02 08:20:15.142805	2022-04-02 08:20:15.142805	0	Sem afastamento
22	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-04-02 08:20:28.583213	2024-03-19 00:00:00	197	Viagem de Negocios
23	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 08:52:43.776221	2027-08-20 00:00:00	6096	Sem afastamento 
24	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 08:58:25.152268	2027-08-20 00:00:00	6095	Sem afastamento 
25	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 09:18:48.915658	2027-08-20 00:00:00	6094	Sem afastamento 
26	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-04-02 09:39:03.84715	2027-08-20 00:00:00	499	Sem afastamento 
27	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				34563217	INVALIDA	Entrada	2022-04-02 09:41:19.197544	2022-04-02 09:41:19.197544	0	Sem afastamento
28	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				34563217	INVALIDA	Entrada	2022-04-02 09:50:29.137091	2022-04-02 09:50:29.137091	0	Sem afastamento
29	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				34563217	INVALIDA	Entrada	2022-04-02 10:00:35.440036	2022-04-02 10:00:35.440036	0	Sem afastamento
30	ACESSO LIBERADO	Cleopatra	do Egito			15BB69DA	ATIVA	Entrada	2022-04-02 10:01:10.226464	2025-08-20 00:00:00	27	Sem afastamento 
31	ACESSO NEGADO: Credencial vencida ou inativa no momento	Gaspazinho	do Pertepan			55558GGS	ATIVA	Entrada	2022-04-02 10:03:22.34927	2021-08-20 00:00:00	45453	Sem afastamento 
32	ACESSO LIBERADO	Josefa	Do Milagre			3PGN6MOW	ATIVA	Entrada	2022-04-02 10:03:46.218434	2025-08-20 00:00:00	28	Sem afastamento 
33	ACESSO LIBERADO	Josefa	Do Milagre			3PGN6MOW	ATIVA	Entrada	2022-04-02 10:03:52.980945	2025-08-20 00:00:00	27	Sem afastamento 
34	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Entrada	2022-04-02 12:26:44.905345	2025-08-20 00:00:00	1013	Sem afastamento 
35	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Entrada	2022-04-02 14:11:44.245271	2025-08-20 00:00:00	1012	Sem afastamento 
36	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 14:12:28.901893	2027-08-20 00:00:00	6093	Sem afastamento 
37	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-05-07 17:00:28.625786	2027-08-20 00:00:00	618	Sem afastamento 
38	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				1	INVALIDA	Entrada	2022-05-08 21:32:21.053537	2022-05-08 21:32:21.053537	0	Sem afastamento
39	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				1	INVALIDA	Entrada	2022-05-09 18:55:36.760239	2022-05-09 18:55:36.760239	0	Sem afastamento
40	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:56:01.99024	2022-05-09 18:56:01.99024	0	Sem afastamento
41	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:56:27.473007	2022-05-09 18:56:27.473007	0	Sem afastamento
42	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:56:31.016048	2022-05-09 18:56:31.016048	0	Sem afastamento
43	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:56:41.422404	2022-05-09 18:56:41.422404	0	Sem afastamento
44	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:56:44.170102	2022-05-09 18:56:44.170102	0	Sem afastamento
45	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:56:48.504879	2022-05-09 18:56:48.504879	0	Sem afastamento
46	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:56:50.87094	2022-05-09 18:56:50.87094	0	Sem afastamento
47	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:57:17.443821	2022-05-09 18:57:17.443821	0	Sem afastamento
48	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:57:24.68524	2022-05-09 18:57:24.68524	0	Sem afastamento
49	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:58:03.559874	2022-05-09 18:58:03.559874	0	Sem afastamento
50	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:58:13.760161	2022-05-09 18:58:13.760161	0	Sem afastamento
51	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 18:58:24.108568	2024-03-19 00:00:00	200	Viagem de Negocios
52	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:58:25.579659	2022-05-09 18:58:25.579659	0	Sem afastamento
53	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 18:58:55.184165	2022-05-09 18:58:55.184165	0	Sem afastamento
54	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 18:59:02.31918	2024-03-19 00:00:00	199	Viagem de Negocios
55	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-05-09 19:01:56.305989	2027-08-20 00:00:00	498	Sem afastamento 
56	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-05-09 19:02:05.854846	2027-08-20 00:00:00	497	Sem afastamento 
57	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 19:03:24.939307	2024-03-19 00:00:00	198	Viagem de Negocios
58	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				1	INVALIDA	Entrada	2022-05-09 19:03:29.214615	2022-05-09 19:03:29.214615	0	Sem afastamento
59	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	Entrada	2022-05-09 19:03:43.255904	2022-05-09 19:03:43.255904	0	Sem afastamento
60	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				joaodev	INVALIDA	Entrada	2022-05-09 19:04:12.366387	2022-05-09 19:04:12.366387	0	Sem afastamento
61	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				dsadsa	INVALIDA	\N	2022-05-09 19:05:11.05999	2022-05-09 19:05:11.05999	0	Sem afastamento
62	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				dsadas	INVALIDA	\N	2022-05-09 19:07:31.338442	2022-05-09 19:07:31.338442	0	Sem afastamento
63	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				dsadsa	INVALIDA	\N	2022-05-09 19:17:59.10268	2022-05-09 19:17:59.10268	0	Sem afastamento
64	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 19:18:31.000511	2024-03-19 00:00:00	197	Viagem de Negocios
65	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-05-09 19:18:52.808112	2027-08-20 00:00:00	617	Sem afastamento 
66	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:27:44.125146	2022-05-09 19:27:44.125146	0	Sem afastamento
67	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				ANA	INVALIDA	\N	2022-05-09 19:27:58.749766	2022-05-09 19:27:58.749766	0	Sem afastamento
68	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:09.876684	2027-08-20 00:00:00	6092	Sem afastamento 
69	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:11.494541	2027-08-20 00:00:00	6091	Sem afastamento 
70	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:11.932598	2027-08-20 00:00:00	6090	Sem afastamento 
71	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:12.149825	2027-08-20 00:00:00	6089	Sem afastamento 
72	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:34.283756	2027-08-20 00:00:00	6088	Sem afastamento 
73	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:49.254743	2027-08-20 00:00:00	6087	Sem afastamento 
74	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:33:32.283369	2022-05-09 19:33:32.283369	0	Sem afastamento
75	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:34:34.833492	2022-05-09 19:34:34.833492	0	Sem afastamento
76	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				987654321	INVALIDA	\N	2022-05-09 19:36:31.394661	2022-05-09 19:36:31.394661	0	Sem afastamento
77	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				987654321	INVALIDA	\N	2022-05-09 19:36:35.465482	2022-05-09 19:36:35.465482	0	Sem afastamento
78	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				987654321	INVALIDA	\N	2022-05-09 19:36:41.988978	2022-05-09 19:36:41.988978	0	Sem afastamento
79	ACESSO NEGADO: Credencial vencida ou inativa no momento	Gaspazinho	do Pertepan			55558GGS	ATIVA	Entrada	2022-05-09 19:38:15.133708	2021-08-20 00:00:00	45452	Sem afastamento 
80	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:38:56.951961	2027-08-20 00:00:00	498	Sem afastamento 
81	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:39:31.665338	2027-08-20 00:00:00	497	Sem afastamento 
82	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:40:13.78981	2027-08-20 00:00:00	496	Sem afastamento 
83	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				joaodev	INVALIDA	Saida	2022-05-09 19:41:09.214844	2022-05-09 19:41:09.214844	0	Sem afastamento
84	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:41:33.854384	2022-05-09 19:41:33.854384	0	Sem afastamento
85	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:41:58.230761	2022-05-09 19:41:58.230761	0	Sem afastamento
86	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:42:19.319114	2022-05-09 19:42:19.319114	0	Sem afastamento
87	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:42:59.042253	2022-05-09 19:42:59.042253	0	Sem afastamento
88	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:43:24.741048	2022-05-09 19:43:24.741048	0	Sem afastamento
89	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:43:47.171212	2022-05-09 19:43:47.171212	0	Sem afastamento
90	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:43:52.017642	2022-05-09 19:43:52.017642	0	Sem afastamento
91	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	\N	2022-05-09 19:44:13.686046	2022-05-09 19:44:13.686046	0	Sem afastamento
92	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				dsad	INVALIDA	Entrada	2022-05-09 19:44:48.257365	2022-05-09 19:44:48.257365	0	Sem afastamento
93	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:10.430883	2027-08-20 00:00:00	495	Sem afastamento 
94	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:13.955504	2027-08-20 00:00:00	494	Sem afastamento 
95	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:30.256503	2027-08-20 00:00:00	493	Sem afastamento 
96	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:46.813504	2027-08-20 00:00:00	492	Sem afastamento 
97	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	Entrada	2022-05-09 19:46:26.97583	2022-05-09 19:46:26.97583	0	Sem afastamento
98	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	Saida	2022-05-09 19:46:44.271729	2022-05-09 19:46:44.271729	0	Sem afastamento
99	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:46:57.288595	2027-08-20 00:00:00	491	Sem afastamento 
100	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	Entrada	2022-05-09 19:47:48.655673	2022-05-09 19:47:48.655673	0	Sem afastamento
101	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	Saida	2022-05-09 19:47:54.559703	2022-05-09 19:47:54.559703	0	Sem afastamento
102	ACESSO LIBERADO	Aurentina	Alves			AAAAA5	ATIVO	Entrada	2022-05-09 20:03:54.045966	2022-05-31 20:08:00	1555	Sem afastamento 
103	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				8888vcv	INVALIDA	Entrada	2022-05-09 20:06:07.411854	2022-05-09 20:06:07.411854	0	Sem afastamento
104	ACESSO NEGADO: Credencial vencida ou inativa no momento	Aurentina	Alves			AAAAA5	ATIVO	Entrada	2022-05-09 20:07:17.836969	2021-05-31 20:08:00	1554	Sem afastamento 
105	ACESSO LIBERADO	Wanderson	Tito de Souza			34563217	ATIVO	Entrada	2022-05-09 20:13:17.059618	2022-05-27 20:09:00	52222	Sem afastamento 
106	ACESSO LIBERADO	Wanderson	Tito de Souza			34563217	ATIVO	Entrada	2022-05-09 20:13:51.535696	2022-05-27 20:09:00	52221	Sem afastamento 
107	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				34563217	INVALIDA	Saida	2022-05-09 20:15:18.171343	2022-05-09 20:15:18.171343	0	Sem afastamento
108	ACESSO NEGADO: Credencial vencida ou inativa no momento	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-09 20:51:00.626208	2022-05-08 17:32:00	3333	Sem afastamento 
109	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-09 20:51:34.571091	2024-05-08 17:32:00	3332	Sem afastamento 
110	ACESSO LIBERADO	Haanna	Montana			TTOI8888	ATIVA	Entrada	2022-05-09 20:56:01.239551	2027-08-20 00:00:00	1566	Sem afastamento 
111	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-10 14:59:31.799437	2025-08-20 00:00:00	28	Sem afastamento 
112	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				sssss	INVALIDA	Entrada	2022-05-10 15:06:12.372843	2022-05-10 15:06:12.372843	0	Sem afastamento
113	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				sssss	INVALIDA	Saida	2022-05-10 15:06:15.939886	2022-05-10 15:06:15.939886	0	Sem afastamento
114	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				dsadsa	INVALIDA	Entrada	2022-05-10 16:01:09.872835	2022-05-10 16:01:09.872835	0	Sem afastamento
115	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				dsds	INVALIDA	Entrada	2022-05-10 16:04:06.106585	2022-05-10 16:04:06.106585	0	Sem afastamento
116	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA		2022-05-10 16:06:01.983468	2022-05-10 16:06:01.983468	0	Sem afastamento
117	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				ss	INVALIDA		2022-05-10 16:06:08.746479	2022-05-10 16:06:08.746479	0	Sem afastamento
118	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				ss	INVALIDA		2022-05-10 16:10:54.732563	2022-05-10 16:10:54.732563	0	Sem afastamento
119	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				ss	INVALIDA	Entrada	2022-05-10 16:10:58.270544	2022-05-10 16:10:58.270544	0	Sem afastamento
120	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				ds	INVALIDA	Entrada	2022-05-10 16:11:09.468264	2022-05-10 16:11:09.468264	0	Sem afastamento
121	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos					INVALIDA	Entrada	2022-05-10 16:11:22.490071	2022-05-10 16:11:22.490071	0	Sem afastamento
122	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				s	INVALIDA	Entrada	2022-05-10 16:12:07.259391	2022-05-10 16:12:07.259391	0	Sem afastamento
123	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				SSS	INVALIDA	Entrada	2022-05-10 16:12:55.299208	2022-05-10 16:12:55.299208	0	Sem afastamento
124	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Entrada	2022-05-11 19:25:05.978225	2027-08-20 00:00:00	1566	Sem afastamento 
125	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Entrada	2022-05-11 19:25:09.575247	2027-08-20 00:00:00	1565	Sem afastamento 
126	ACESSO NEGADO: Credencial vencida ou inativa no momento	Nobre	Vasco Ramos			909888*?#@*	ATIVA	Entrada	2022-05-11 19:25:34.24498	2021-08-20 00:00:00	200	Sem afastamento 
127	ACESSO LIBERADO	Gabriel	Camargo Santos			W28EX63L	ATIVA	Entrada	2022-05-11 19:25:58.732164	2025-08-20 00:00:00	1015	Sem afastamento 
128	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Entrada	2022-05-11 19:27:07.002346	2025-08-20 00:00:00	5522	Sem afastamento 
129	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Entrada	2022-05-11 19:27:10.179927	2025-08-20 00:00:00	5521	Sem afastamento 
130	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Entrada	2022-05-12 10:08:46.170287	2022-11-17 10:06:00	5000	Sem afastamento 
131	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-12 14:10:54.285354	2025-08-20 00:00:00	27	Sem afastamento 
132	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Saida	2022-05-12 14:11:04.845526	2027-08-20 00:00:00	1564	Sem afastamento 
133	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Saida	2022-05-12 14:11:12.165235	2027-08-20 00:00:00	496	Sem afastamento 
134	ACESSO LIBERADO	Gabriel	Camargo Santos			W28EX63L	ATIVA	Entrada	2022-05-12 14:11:24.552648	2025-08-20 00:00:00	1014	Sem afastamento 
135	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Saida	2022-05-12 14:11:34.934827	2027-08-20 00:00:00	497	Sem afastamento 
136	ACESSO LIBERADO	Cleopatra	do Egito			15BB69DA	ATIVA	Saida	2022-05-12 14:11:43.785863	2025-08-20 00:00:00	26	Sem afastamento 
137	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				=EG48GUZUE	INVALIDA	Saida	2022-05-12 14:11:52.102573	2022-05-12 14:11:52.102573	0	Sem afastamento
138	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Saida	2022-05-12 14:11:58.328028	2027-08-20 00:00:00	6086	Sem afastamento 
139	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Saida	2022-05-12 14:12:05.52084	2027-08-20 00:00:00	45453	Sem afastamento 
140	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				JOAOG	INVALIDA	Saida	2022-05-12 14:12:11.352932	2022-05-12 14:12:11.352932	0	Sem afastamento
141	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				JOAOGUI	INVALIDA	Saida	2022-05-12 14:12:19.150626	2022-05-12 14:12:19.150626	0	Sem afastamento
142	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-12 14:13:04.125795	2022-11-17 10:06:00	4999	Sem afastamento 
143	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				5555556	INVALIDA	Entrada	2022-05-13 20:59:55.529883	2022-05-13 20:59:55.529883	0	Sem afastamento
144	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Entrada	2022-05-13 21:06:16.202246	2027-08-20 00:00:00	1563	Sem afastamento 
145	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Entrada	2022-05-13 21:07:36.093856	2025-08-20 00:00:00	5520	Sem afastamento 
146	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Saida	2022-05-13 21:07:48.282052	2025-08-20 00:00:00	5519	Sem afastamento 
147	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Saida	2022-05-13 21:08:10.313618	2025-08-20 00:00:00	1011	Sem afastamento 
148	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Entrada	2022-05-13 21:08:13.555667	2025-08-20 00:00:00	1010	Sem afastamento 
149	ACESSO NEGADO: Credencial vencida ou inativa	BALACOS	Lopes			619ZC9	ATIVA	Entrada	2022-05-13 21:08:46.405954	2025-08-20 00:00:00	1019	Inatividade por Servicos Exteriores
150	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Saida	2022-05-13 21:09:09.458874	2027-08-20 00:00:00	496	Sem afastamento 
151	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-05-13 21:09:12.595549	2027-08-20 00:00:00	495	Sem afastamento 
152	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Entrada	2022-05-13 21:09:33.458095	2027-08-20 00:00:00	45452	Sem afastamento 
153	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Saida	2022-05-13 21:09:35.994815	2027-08-20 00:00:00	45451	Sem afastamento 
154	ACESSO LIBERADO	Haanna	Montana			TTOI8888	ATIVA	Saida	2022-05-13 21:09:50.487733	2027-08-20 00:00:00	1565	Sem afastamento 
155	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:26:05.025036	2025-08-20 00:00:00	26	Sem afastamento 
156	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:26:31.606304	2025-08-20 00:00:00	25	Sem afastamento 
157	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				Yttt	INVALIDA	Saida	2022-05-13 21:26:44.713331	2022-05-13 21:26:44.713331	0	Sem afastamento
158	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:27:17.752633	2025-08-20 00:00:00	24	Sem afastamento 
159	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:27:35.72244	2025-08-20 00:00:00	23	Sem afastamento 
160	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-13 21:27:58.66954	2022-11-17 10:06:00	4998	Sem afastamento 
161	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA		2022-05-13 21:38:59.57391	2025-08-20 00:00:00	22	Sem afastamento 
162	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:39:03.330753	2025-08-20 00:00:00	21	Sem afastamento 
163	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Saida	2022-05-13 21:39:35.670612	2028-07-26 21:37:00	100000	Sem afastamento 
164	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Entrada	2022-05-13 21:41:50.253321	2022-11-17 10:06:00	4997	Sem afastamento 
165	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Saida	2022-05-13 21:47:00.502053	2028-07-26 21:37:00	99999	Sem afastamento 
166	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-14 14:40:44.76461	2025-08-20 00:00:00	20	Sem afastamento 
167	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-14 14:41:58.097374	2022-11-17 10:06:00	4996	Sem afastamento 
168	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				DDD	INVALIDA	Saida	2022-05-14 14:42:21.071897	2022-05-14 14:42:21.071897	0	Sem afastamento
169	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Saida	2022-05-14 14:42:46.492684	2028-07-26 21:37:00	99998	Sem afastamento 
170	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Entrada	2022-05-14 14:42:52.788182	2028-07-26 21:37:00	99997	Sem afastamento 
171	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-14 18:08:48.104739	2025-08-20 00:00:00	19	Sem afastamento 
172	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-14 18:09:30.777822	2025-08-20 00:00:00	18	Sem afastamento 
173	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Entrada	2022-05-14 18:09:54.723526	2022-11-17 10:06:00	4995	Sem afastamento 
174	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-14 18:10:07.856833	2022-11-17 10:06:00	4994	Sem afastamento 
175	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Entrada	2022-05-14 18:16:25.723484	2025-06-14 18:16:00	800000	Sem afastamento 
176	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Saida	2022-05-14 18:16:35.351598	2025-06-14 18:16:00	799999	Sem afastamento 
177	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				55677	INVALIDA	Saida	2022-05-14 20:10:44.922104	2022-05-14 20:10:44.922104	0	Sem afastamento
178	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				5788	INVALIDA	Saida	2022-05-14 20:11:04.188014	2022-05-14 20:11:04.188014	0	Sem afastamento
179	ACESSO NEGADO: Credencial vencida ou inativa	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-14 20:11:18.837604	2024-03-19 00:00:00	196	Viagem de Negocios
180	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				ABCDF	INVALIDA	Entrada	2022-05-16 09:18:05.601484	2022-05-16 09:18:05.601484	0	Sem afastamento
181	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-16 09:27:51.326173	2024-05-08 17:32:00	3331	Sem afastamento 
182	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Saida	2022-05-16 09:28:57.386152	2024-05-08 17:32:00	3330	Sem afastamento 
183	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-05-16 09:36:41.613396	2027-08-20 00:00:00	495	Sem afastamento 
184	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-16 09:59:11.810451	2027-08-20 00:00:00	6085	Sem afastamento 
185	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Entrada	2022-05-16 14:30:39.381373	2025-06-14 18:16:00	799998	Sem afastamento 
186	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Saida	2022-05-16 14:30:42.402265	2025-06-14 18:16:00	799997	Sem afastamento 
187	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-16 14:30:50.821998	2025-08-20 00:00:00	17	Sem afastamento 
188	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-16 14:30:53.64643	2025-08-20 00:00:00	16	Sem afastamento 
189	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-16 16:48:52.302813	2025-08-20 00:00:00	15	Sem afastamento 
190	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-16 16:48:55.232739	2025-08-20 00:00:00	14	Sem afastamento 
191	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-16 16:49:00.66139	2025-08-20 00:00:00	13	Sem afastamento 
192	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				JOAO	INVALIDA	Entrada	2022-05-16 16:49:07.890744	2022-05-16 16:49:07.890744	0	Sem afastamento
193	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Entrada	2022-05-16 16:49:48.308466	2027-08-20 00:00:00	45450	Sem afastamento 
194	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-16 18:01:07.769349	2025-08-20 00:00:00	12	Sem afastamento 
195	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-17 12:05:53.809888	2025-08-20 00:00:00	11	Sem afastamento 
196	ACESSO LIBERADO	Caio	Júlio Cesar			1606BD1Q8	ATIVO	Entrada	2022-05-17 20:56:23.398027	2026-05-27 20:43:00	900000	Sem afastamento 
197	ACESSO LIBERADO	Caio	Júlio Cesar			1606BD1Q8	ATIVO	Saida	2022-05-17 20:56:43.183294	2026-05-27 20:43:00	899999	Sem afastamento 
198	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-17 20:57:09.812878	2025-08-20 00:00:00	10	Sem afastamento 
199	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-17 20:57:18.402923	2025-08-20 00:00:00	9	Sem afastamento 
200	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Entrada	2022-05-18 09:05:30.287497	2025-06-14 18:16:00	799996	Sem afastamento 
201	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Saida	2022-05-18 09:05:41.409629	2025-06-14 18:16:00	799995	Sem afastamento 
202	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-18 09:05:55.900191	2025-08-20 00:00:00	8	Sem afastamento 
203	ACESSO LIBERADO	Michelangelo	di Lodovico			MICHELANGELO	ATIVO	Entrada	2022-05-18 10:49:55.04314	2023-11-18 10:34:00	1564	Sem afastamento 
204	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-18 10:50:25.924266	2024-05-08 17:32:00	3329	Sem afastamento 
205	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Entrada	2022-05-18 10:50:49.7767	2031-06-10 09:17:00	100000	Sem afastamento 
206	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-05-18 10:51:10.485426	2025-10-01 09:32:00	1199	Sem afastamento 
207	ACESSO LIBERADO	Pedro	Álvares Cabral			PEDRO	ATIVO	Entrada	2022-05-18 10:51:33.713812	2026-11-18 09:41:00	1520	Sem afastamento 
208	ACESSO LIBERADO	Cristóvão	Colombo			COLOMBO	ATIVO	Entrada	2022-05-18 10:51:53.198802	2022-05-26 09:46:00	1451	Sem afastamento 
209	ACESSO LIBERADO	Leonardo	da Vinci			MONALISA	ATIVO	Entrada	2022-05-18 10:52:22.62811	2024-07-10 09:58:00	1519	Sem afastamento 
210	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Entrada	2022-05-18 10:53:37.088593	2024-03-02 09:50:00	1954	Sem afastamento 
211	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Saida	2022-05-18 10:53:40.103336	2024-03-02 09:50:00	1953	Sem afastamento 
212	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Saida	2022-05-18 12:25:24.423902	2031-06-10 09:17:00	99999	Sem afastamento 
213	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Entrada	2022-05-18 12:25:34.310654	2031-06-10 09:17:00	99998	Sem afastamento 
214	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Saida	2022-05-18 12:25:37.911013	2031-06-10 09:17:00	99997	Sem afastamento 
215	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-18 16:43:34.95934	2024-05-08 17:32:00	3328	Sem afastamento 
216	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Saida	2022-05-18 16:43:38.008196	2024-05-08 17:32:00	3327	Sem afastamento 
217	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				HHGBDB	INVALIDA	Entrada	2022-05-18 16:47:51.475576	2022-05-18 16:47:51.475576	0	Sem afastamento
218	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				HHGBDB	INVALIDA	Entrada	2022-05-18 16:48:25.741534	2022-05-18 16:48:25.741534	0	Sem afastamento
219	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Saida	2022-05-18 16:48:42.729325	2031-06-10 09:17:00	99996	Sem afastamento 
220	ACESSO NEGADO: Credencial vencida ou inativa	Tutankhamon	Décimo Oitavo			TUTAN	ATIVO	Entrada	2022-05-18 16:58:12.8946	2024-06-24 16:52:00	1000	Ferias
221	ACESSO NEGADO: Credencial vencida ou inativa	Tutankhamon	Décimo Oitavo			TUTAN	ATIVO	Entrada	2022-05-18 16:59:02.122265	2024-06-24 16:52:00	999	Ferias
222	ACESSO LIBERADO	Leonardo	da Vinci			MONALISA	ATIVO	Saida	2022-05-18 18:15:09.246041	2024-07-10 09:58:00	1518	Sem afastamento 
223	ACESSO NEGADO: Credencial vencida ou inativa	Tutankhamon	Décimo Oitavo			TUTAN	ATIVO	Entrada	2022-05-18 18:28:21.059358	2024-06-24 16:52:00	998	Ferias
224	ACESSO LIBERADO	Leonardo	da Vinci			MONALISA	ATIVO	Entrada	2022-05-18 18:29:01.790359	2024-07-10 09:58:00	1517	Sem afastamento 
225	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-05-19 16:00:37.815434	2025-10-01 09:32:00	1198	Sem afastamento 
226	ACESSO LIBERADO	Usuário	De Teste			TESTE	ATIVO	Entrada	2022-05-19 19:14:33.257462	2024-06-19 12:01:00	1000	Sem afastamento 
227	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				HHGBDB\t	INVALIDA	Entrada	2022-05-21 09:07:22.314867	2022-05-21 09:07:22.314867	0	Sem afastamento
228	ACESSO LIBERADO	Cristóvão	Colombo			COLOMBO	ATIVO	Entrada	2022-05-21 09:07:45.186722	2022-05-26 09:46:00	1450	Sem afastamento 
229	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-05-21 09:08:02.942039	2025-10-01 09:32:00	1197	Sem afastamento 
230	ACESSO LIBERADO	Cristóvão	Colombo			COLOMBO	ATIVO	Saida	2022-05-21 09:08:12.233038	2022-05-26 09:46:00	1449	Sem afastamento 
231	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Saida	2022-05-21 10:28:02.837496	2025-10-01 09:32:00	1196	Sem afastamento 
232	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				444545	INVALIDA	Entrada	2022-06-11 20:01:02.560316	2022-06-11 20:01:02.560316	0	Sem afastamento
233	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Entrada	2022-06-11 20:01:27.237873	2024-03-02 09:50:00	1952	Sem afastamento 
234	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Saida	2022-06-11 20:01:30.966611	2024-03-02 09:50:00	1951	Sem afastamento 
235	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Saida	2022-06-11 20:01:45.222847	2025-10-01 09:32:00	1195	Sem afastamento 
236	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-06-11 20:01:48.28713	2025-10-01 09:32:00	1194	Sem afastamento 
237	ACESSO LIBERADO	Pedro	Álvares Cabral			PEDRO	ATIVO	Entrada	2022-06-11 20:01:55.16388	2026-11-18 09:41:00	1519	Sem afastamento 
238	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Saida	2022-06-11 20:02:04.05585	2024-03-02 09:50:00	1950	Sem afastamento 
\.


--
-- TOC entry 2976 (class 0 OID 16636)
-- Dependencies: 204
-- Data for Name: tb_relatorios_acessos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_relatorios_acessos (id_relatorio, acesso_relatorio, nome_relatorio, sobrenome_relatorio, tipo_documento_relatorio, numero_documento_relatorio, credencial_relatorio, situacao_credencial_relatorio, direcao_relatorio, data_acesso_relatorio, data_final_relatorio, restam_acessos_relatorio, situacao_afastamento_relatorio) FROM stdin;
39	situacao_do_acesso	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-04-01 21:35:15.607092	2024-03-19 00:00:00	199	Viagem de Negocios
40	ACESSO NEGADO por Credencial vencida ou invalida	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-04-01 21:37:58.859717	2024-03-19 00:00:00	198	Viagem de Negocios
41	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-04-01 21:42:47.1216	2027-08-20 00:00:00	620	Sem afastamento 
42	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-04-01 21:42:54.753774	2027-08-20 00:00:00	619	Sem afastamento 
43	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				3	INVALIDA	Saida	2022-04-01 21:43:02.859546	2022-04-01 21:43:02.859546	0	Sem afastamento
44	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				556545SSDF	INVALIDA	Saida	2022-04-01 21:49:18.986914	2022-04-01 21:49:18.986914	0	Sem afastamento
45	ACESSO NEGADO por Credencial vencida ou invalida	Salomao	Quake			THBSHI995A	ATIVA	Entrada	2022-04-01 21:49:27.300591	2025-08-20 00:00:00	1013	Inatividade por Servicos Exteriores
46	ACESSO LIBERADO	Cleopatra	do Egito			15BB69DA	ATIVA	Entrada	2022-04-01 21:49:45.569274	2025-08-20 00:00:00	28	Sem afastamento 
47	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-04-01 21:55:34.17551	2027-08-20 00:00:00	500	Sem afastamento 
48	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-04-01 21:55:57.894085	2027-08-20 00:00:00	499	Sem afastamento 
49	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-04-01 21:56:23.217339	2027-08-20 00:00:00	500	Sem afastamento 
50	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-04-01 21:56:34.240814	2027-08-20 00:00:00	500	Sem afastamento 
51	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-04-01 21:56:39.366509	2027-08-20 00:00:00	499	Sem afastamento 
52	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-01 21:57:07.806458	2027-08-20 00:00:00	6100	Sem afastamento 
53	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-01 21:57:13.881812	2027-08-20 00:00:00	6099	Sem afastamento 
54	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-04-01 22:27:23.133749	2027-08-20 00:00:00	498	Sem afastamento 
55	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 06:57:48.385847	2027-08-20 00:00:00	6098	Sem afastamento 
56	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 08:10:39.097114	2027-08-20 00:00:00	6097	Sem afastamento 
57	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				Salomao	INVALIDA	Entrada	2022-04-02 08:20:15.142805	2022-04-02 08:20:15.142805	0	Sem afastamento
58	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-04-02 08:20:28.583213	2024-03-19 00:00:00	197	Viagem de Negocios
59	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 08:52:43.776221	2027-08-20 00:00:00	6096	Sem afastamento 
60	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 08:58:25.152268	2027-08-20 00:00:00	6095	Sem afastamento 
61	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 09:18:48.915658	2027-08-20 00:00:00	6094	Sem afastamento 
62	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-04-02 09:39:03.84715	2027-08-20 00:00:00	499	Sem afastamento 
63	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				34563217	INVALIDA	Entrada	2022-04-02 09:41:19.197544	2022-04-02 09:41:19.197544	0	Sem afastamento
64	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				34563217	INVALIDA	Entrada	2022-04-02 09:50:29.137091	2022-04-02 09:50:29.137091	0	Sem afastamento
65	ACESSO BARRADO	Credencial Inexistente ou Sem Creditos				34563217	INVALIDA	Entrada	2022-04-02 10:00:35.440036	2022-04-02 10:00:35.440036	0	Sem afastamento
66	ACESSO LIBERADO	Cleopatra	do Egito			15BB69DA	ATIVA	Entrada	2022-04-02 10:01:10.226464	2025-08-20 00:00:00	27	Sem afastamento 
67	ACESSO NEGADO: Credencial vencida ou inativa no momento	Gaspazinho	do Pertepan			55558GGS	ATIVA	Entrada	2022-04-02 10:03:22.34927	2021-08-20 00:00:00	45453	Sem afastamento 
68	ACESSO LIBERADO	Josefa	Do Milagre			3PGN6MOW	ATIVA	Entrada	2022-04-02 10:03:46.218434	2025-08-20 00:00:00	28	Sem afastamento 
69	ACESSO LIBERADO	Josefa	Do Milagre			3PGN6MOW	ATIVA	Entrada	2022-04-02 10:03:52.980945	2025-08-20 00:00:00	27	Sem afastamento 
70	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Entrada	2022-04-02 12:26:44.905345	2025-08-20 00:00:00	1013	Sem afastamento 
71	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Entrada	2022-04-02 14:11:44.245271	2025-08-20 00:00:00	1012	Sem afastamento 
72	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-04-02 14:12:28.901893	2027-08-20 00:00:00	6093	Sem afastamento 
73	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-05-07 17:00:28.625786	2027-08-20 00:00:00	618	Sem afastamento 
74	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 18:58:24.108568	2024-03-19 00:00:00	200	Viagem de Negocios
75	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 18:59:02.31918	2024-03-19 00:00:00	199	Viagem de Negocios
76	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-05-09 19:01:56.305989	2027-08-20 00:00:00	498	Sem afastamento 
77	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-05-09 19:02:05.854846	2027-08-20 00:00:00	497	Sem afastamento 
78	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 19:03:24.939307	2024-03-19 00:00:00	198	Viagem de Negocios
79	ACESSO NEGADO: Credencial vencida ou inativa no momento	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-09 19:18:31.000511	2024-03-19 00:00:00	197	Viagem de Negocios
80	ACESSO LIBERADO	Romero Brito	Abuquerque			987456321	ATIVA	Entrada	2022-05-09 19:18:52.808112	2027-08-20 00:00:00	617	Sem afastamento 
81	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:09.876684	2027-08-20 00:00:00	6092	Sem afastamento 
82	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:11.494541	2027-08-20 00:00:00	6091	Sem afastamento 
83	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:11.932598	2027-08-20 00:00:00	6090	Sem afastamento 
84	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:12.149825	2027-08-20 00:00:00	6089	Sem afastamento 
85	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:34.283756	2027-08-20 00:00:00	6088	Sem afastamento 
86	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-09 19:32:49.254743	2027-08-20 00:00:00	6087	Sem afastamento 
87	ACESSO NEGADO: Credencial vencida ou inativa no momento	Gaspazinho	do Pertepan			55558GGS	ATIVA	Entrada	2022-05-09 19:38:15.133708	2021-08-20 00:00:00	45452	Sem afastamento 
88	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:38:56.951961	2027-08-20 00:00:00	498	Sem afastamento 
89	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:39:31.665338	2027-08-20 00:00:00	497	Sem afastamento 
90	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:40:13.78981	2027-08-20 00:00:00	496	Sem afastamento 
91	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:10.430883	2027-08-20 00:00:00	495	Sem afastamento 
92	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:13.955504	2027-08-20 00:00:00	494	Sem afastamento 
93	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:30.256503	2027-08-20 00:00:00	493	Sem afastamento 
94	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:45:46.813504	2027-08-20 00:00:00	492	Sem afastamento 
95	ACESSO LIBERADO	Romilda	Caxalote do Mar			DU50UW9FB	ATIVA	Entrada	2022-05-09 19:46:57.288595	2027-08-20 00:00:00	491	Sem afastamento 
96	ACESSO LIBERADO	Aurentina	Alves			AAAAA5	ATIVO	Entrada	2022-05-09 20:03:54.045966	2022-05-31 20:08:00	1555	Sem afastamento 
97	ACESSO NEGADO: Credencial vencida ou inativa no momento	Aurentina	Alves			AAAAA5	ATIVO	Entrada	2022-05-09 20:07:17.836969	2021-05-31 20:08:00	1554	Sem afastamento 
98	ACESSO LIBERADO	Wanderson	Tito de Souza			34563217	ATIVO	Entrada	2022-05-09 20:13:17.059618	2022-05-27 20:09:00	52222	Sem afastamento 
99	ACESSO LIBERADO	Wanderson	Tito de Souza			34563217	ATIVO	Entrada	2022-05-09 20:13:51.535696	2022-05-27 20:09:00	52221	Sem afastamento 
100	ACESSO NEGADO: Credencial vencida ou inativa no momento	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-09 20:51:00.626208	2022-05-08 17:32:00	3333	Sem afastamento 
101	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-09 20:51:34.571091	2024-05-08 17:32:00	3332	Sem afastamento 
102	ACESSO LIBERADO	Haanna	Montana			TTOI8888	ATIVA	Entrada	2022-05-09 20:56:01.239551	2027-08-20 00:00:00	1566	Sem afastamento 
103	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-10 14:59:31.799437	2025-08-20 00:00:00	28	Sem afastamento 
104	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Entrada	2022-05-11 19:25:05.978225	2027-08-20 00:00:00	1566	Sem afastamento 
105	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Entrada	2022-05-11 19:25:09.575247	2027-08-20 00:00:00	1565	Sem afastamento 
106	ACESSO NEGADO: Credencial vencida ou inativa no momento	Nobre	Vasco Ramos			909888*?#@*	ATIVA	Entrada	2022-05-11 19:25:34.24498	2021-08-20 00:00:00	200	Sem afastamento 
107	ACESSO LIBERADO	Gabriel	Camargo Santos			W28EX63L	ATIVA	Entrada	2022-05-11 19:25:58.732164	2025-08-20 00:00:00	1015	Sem afastamento 
108	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Entrada	2022-05-11 19:27:07.002346	2025-08-20 00:00:00	5522	Sem afastamento 
109	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Entrada	2022-05-11 19:27:10.179927	2025-08-20 00:00:00	5521	Sem afastamento 
110	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Entrada	2022-05-12 10:08:46.170287	2022-11-17 10:06:00	5000	Sem afastamento 
111	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-12 14:10:54.285354	2025-08-20 00:00:00	27	Sem afastamento 
112	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Saida	2022-05-12 14:11:04.845526	2027-08-20 00:00:00	1564	Sem afastamento 
113	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Saida	2022-05-12 14:11:12.165235	2027-08-20 00:00:00	496	Sem afastamento 
114	ACESSO LIBERADO	Gabriel	Camargo Santos			W28EX63L	ATIVA	Entrada	2022-05-12 14:11:24.552648	2025-08-20 00:00:00	1014	Sem afastamento 
115	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Saida	2022-05-12 14:11:34.934827	2027-08-20 00:00:00	497	Sem afastamento 
116	ACESSO LIBERADO	Cleopatra	do Egito			15BB69DA	ATIVA	Saida	2022-05-12 14:11:43.785863	2025-08-20 00:00:00	26	Sem afastamento 
117	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Saida	2022-05-12 14:11:58.328028	2027-08-20 00:00:00	6086	Sem afastamento 
118	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Saida	2022-05-12 14:12:05.52084	2027-08-20 00:00:00	45453	Sem afastamento 
119	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-12 14:13:04.125795	2022-11-17 10:06:00	4999	Sem afastamento 
120	ACESSO LIBERADO	Maria	JavaScript			TTOI38888	ATIVA	Entrada	2022-05-13 21:06:16.202246	2027-08-20 00:00:00	1563	Sem afastamento 
121	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Entrada	2022-05-13 21:07:36.093856	2025-08-20 00:00:00	5520	Sem afastamento 
122	ACESSO LIBERADO	Joseania	Catilanga Santana			3PGN6MOW	ATIVA	Saida	2022-05-13 21:07:48.282052	2025-08-20 00:00:00	5519	Sem afastamento 
123	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Saida	2022-05-13 21:08:10.313618	2025-08-20 00:00:00	1011	Sem afastamento 
124	ACESSO LIBERADO	Chica	da Silca			BYJBGZ56	ATIVA	Entrada	2022-05-13 21:08:13.555667	2025-08-20 00:00:00	1010	Sem afastamento 
125	ACESSO NEGADO: Credencial vencida ou inativa	BALACOS	Lopes			619ZC9	ATIVA	Entrada	2022-05-13 21:08:46.405954	2025-08-20 00:00:00	1019	Inatividade por Servicos Exteriores
126	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Saida	2022-05-13 21:09:09.458874	2027-08-20 00:00:00	496	Sem afastamento 
127	ACESSO LIBERADO	Marcin	Do Pneu			WIOP8BM8N	ATIVA	Entrada	2022-05-13 21:09:12.595549	2027-08-20 00:00:00	495	Sem afastamento 
128	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Entrada	2022-05-13 21:09:33.458095	2027-08-20 00:00:00	45452	Sem afastamento 
129	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Saida	2022-05-13 21:09:35.994815	2027-08-20 00:00:00	45451	Sem afastamento 
130	ACESSO LIBERADO	Haanna	Montana			TTOI8888	ATIVA	Saida	2022-05-13 21:09:50.487733	2027-08-20 00:00:00	1565	Sem afastamento 
131	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:26:05.025036	2025-08-20 00:00:00	26	Sem afastamento 
132	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:26:31.606304	2025-08-20 00:00:00	25	Sem afastamento 
133	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:27:17.752633	2025-08-20 00:00:00	24	Sem afastamento 
134	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:27:35.72244	2025-08-20 00:00:00	23	Sem afastamento 
135	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-13 21:27:58.66954	2022-11-17 10:06:00	4998	Sem afastamento 
136	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA		2022-05-13 21:38:59.57391	2025-08-20 00:00:00	22	Sem afastamento 
137	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-13 21:39:03.330753	2025-08-20 00:00:00	21	Sem afastamento 
138	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Saida	2022-05-13 21:39:35.670612	2028-07-26 21:37:00	100000	Sem afastamento 
139	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Entrada	2022-05-13 21:41:50.253321	2022-11-17 10:06:00	4997	Sem afastamento 
140	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Saida	2022-05-13 21:47:00.502053	2028-07-26 21:37:00	99999	Sem afastamento 
141	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-14 14:40:44.76461	2025-08-20 00:00:00	20	Sem afastamento 
142	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-14 14:41:58.097374	2022-11-17 10:06:00	4996	Sem afastamento 
143	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Saida	2022-05-14 14:42:46.492684	2028-07-26 21:37:00	99998	Sem afastamento 
144	ACESSO LIBERADO	Moises	Do Caixote			34563217	ATIVO	Entrada	2022-05-14 14:42:52.788182	2028-07-26 21:37:00	99997	Sem afastamento 
145	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-14 18:08:48.104739	2025-08-20 00:00:00	19	Sem afastamento 
146	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-14 18:09:30.777822	2025-08-20 00:00:00	18	Sem afastamento 
147	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Entrada	2022-05-14 18:09:54.723526	2022-11-17 10:06:00	4995	Sem afastamento 
148	ACESSO LIBERADO	Aurentina	Alvers			JOAO	ATIVO	Saida	2022-05-14 18:10:07.856833	2022-11-17 10:06:00	4994	Sem afastamento 
149	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Entrada	2022-05-14 18:16:25.723484	2025-06-14 18:16:00	800000	Sem afastamento 
150	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Saida	2022-05-14 18:16:35.351598	2025-06-14 18:16:00	799999	Sem afastamento 
151	ACESSO NEGADO: Credencial vencida ou inativa	Jose Alquino	Ramos			123456789	ATIVA	Entrada	2022-05-14 20:11:18.837604	2024-03-19 00:00:00	196	Viagem de Negocios
152	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-16 09:27:51.326173	2024-05-08 17:32:00	3331	Sem afastamento 
153	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Saida	2022-05-16 09:28:57.386152	2024-05-08 17:32:00	3330	Sem afastamento 
154	ACESSO LIBERADO	Kleuza	Cheira Angú			K8PWSX280	ATIVA	Entrada	2022-05-16 09:36:41.613396	2027-08-20 00:00:00	495	Sem afastamento 
155	ACESSO LIBERADO	Ronaldo	Perninha de Grilo			EG48GUZUE	ATIVA	Entrada	2022-05-16 09:59:11.810451	2027-08-20 00:00:00	6085	Sem afastamento 
156	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Entrada	2022-05-16 14:30:39.381373	2025-06-14 18:16:00	799998	Sem afastamento 
157	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Saida	2022-05-16 14:30:42.402265	2025-06-14 18:16:00	799997	Sem afastamento 
158	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-16 14:30:50.821998	2025-08-20 00:00:00	17	Sem afastamento 
159	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-16 14:30:53.64643	2025-08-20 00:00:00	16	Sem afastamento 
160	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-16 16:48:52.302813	2025-08-20 00:00:00	15	Sem afastamento 
161	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-16 16:48:55.232739	2025-08-20 00:00:00	14	Sem afastamento 
162	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-16 16:49:00.66139	2025-08-20 00:00:00	13	Sem afastamento 
163	ACESSO LIBERADO	Joao Guilherme	Tito de Jesus			93S97NQR2	ATIVA	Entrada	2022-05-16 16:49:48.308466	2027-08-20 00:00:00	45450	Sem afastamento 
164	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-16 18:01:07.769349	2025-08-20 00:00:00	12	Sem afastamento 
165	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-17 12:05:53.809888	2025-08-20 00:00:00	11	Sem afastamento 
166	ACESSO LIBERADO	Caio	Júlio Cesar			1606BD1Q8	ATIVO	Entrada	2022-05-17 20:56:23.398027	2026-05-27 20:43:00	900000	Sem afastamento 
167	ACESSO LIBERADO	Caio	Júlio Cesar			1606BD1Q8	ATIVO	Saida	2022-05-17 20:56:43.183294	2026-05-27 20:43:00	899999	Sem afastamento 
168	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Entrada	2022-05-17 20:57:09.812878	2025-08-20 00:00:00	10	Sem afastamento 
169	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-17 20:57:18.402923	2025-08-20 00:00:00	9	Sem afastamento 
170	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Entrada	2022-05-18 09:05:30.287497	2025-06-14 18:16:00	799996	Sem afastamento 
171	ACESSO LIBERADO	Tito	De Souza			1524	ATIVO	Saida	2022-05-18 09:05:41.409629	2025-06-14 18:16:00	799995	Sem afastamento 
172	ACESSO LIBERADO	Mariana	Santos			AAA	ATIVA	Saida	2022-05-18 09:05:55.900191	2025-08-20 00:00:00	8	Sem afastamento 
173	ACESSO LIBERADO	Michelangelo	di Lodovico			MICHELANGELO	ATIVO	Entrada	2022-05-18 10:49:55.04314	2023-11-18 10:34:00	1564	Sem afastamento 
174	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-18 10:50:25.924266	2024-05-08 17:32:00	3329	Sem afastamento 
175	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Entrada	2022-05-18 10:50:49.7767	2031-06-10 09:17:00	100000	Sem afastamento 
176	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-05-18 10:51:10.485426	2025-10-01 09:32:00	1199	Sem afastamento 
177	ACESSO LIBERADO	Pedro	Álvares Cabral			PEDRO	ATIVO	Entrada	2022-05-18 10:51:33.713812	2026-11-18 09:41:00	1520	Sem afastamento 
178	ACESSO LIBERADO	Cristóvão	Colombo			COLOMBO	ATIVO	Entrada	2022-05-18 10:51:53.198802	2022-05-26 09:46:00	1451	Sem afastamento 
179	ACESSO LIBERADO	Leonardo	da Vinci			MONALISA	ATIVO	Entrada	2022-05-18 10:52:22.62811	2024-07-10 09:58:00	1519	Sem afastamento 
180	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Entrada	2022-05-18 10:53:37.088593	2024-03-02 09:50:00	1954	Sem afastamento 
181	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Saida	2022-05-18 10:53:40.103336	2024-03-02 09:50:00	1953	Sem afastamento 
182	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Saida	2022-05-18 12:25:24.423902	2031-06-10 09:17:00	99999	Sem afastamento 
183	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Entrada	2022-05-18 12:25:34.310654	2031-06-10 09:17:00	99998	Sem afastamento 
184	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Saida	2022-05-18 12:25:37.911013	2031-06-10 09:17:00	99997	Sem afastamento 
185	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Entrada	2022-05-18 16:43:34.95934	2024-05-08 17:32:00	3328	Sem afastamento 
186	ACESSO LIBERADO	Teste de Software	Usuario			ABCDEF	ATIVO	Saida	2022-05-18 16:43:38.008196	2024-05-08 17:32:00	3327	Sem afastamento 
187	ACESSO LIBERADO	Cleópatra	VII Filopátor			CLEO	ATIVO	Saida	2022-05-18 16:48:42.729325	2031-06-10 09:17:00	99996	Sem afastamento 
188	ACESSO NEGADO: Credencial vencida ou inativa	Tutankhamon	Décimo Oitavo			TUTAN	ATIVO	Entrada	2022-05-18 16:58:12.8946	2024-06-24 16:52:00	1000	Ferias
189	ACESSO NEGADO: Credencial vencida ou inativa	Tutankhamon	Décimo Oitavo			TUTAN	ATIVO	Entrada	2022-05-18 16:59:02.122265	2024-06-24 16:52:00	999	Ferias
190	ACESSO LIBERADO	Leonardo	da Vinci			MONALISA	ATIVO	Saida	2022-05-18 18:15:09.246041	2024-07-10 09:58:00	1518	Sem afastamento 
191	ACESSO NEGADO: Credencial vencida ou inativa	Tutankhamon	Décimo Oitavo			TUTAN	ATIVO	Entrada	2022-05-18 18:28:21.059358	2024-06-24 16:52:00	998	Ferias
192	ACESSO LIBERADO	Leonardo	da Vinci			MONALISA	ATIVO	Entrada	2022-05-18 18:29:01.790359	2024-07-10 09:58:00	1517	Sem afastamento 
193	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-05-19 16:00:37.815434	2025-10-01 09:32:00	1198	Sem afastamento 
194	ACESSO LIBERADO	Usuário	De Teste			TESTE	ATIVO	Entrada	2022-05-19 19:14:33.257462	2024-06-19 12:01:00	1000	Sem afastamento 
195	ACESSO LIBERADO	Cristóvão	Colombo			COLOMBO	ATIVO	Entrada	2022-05-21 09:07:45.186722	2022-05-26 09:46:00	1450	Sem afastamento 
196	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-05-21 09:08:02.942039	2025-10-01 09:32:00	1197	Sem afastamento 
197	ACESSO LIBERADO	Cristóvão	Colombo			COLOMBO	ATIVO	Saida	2022-05-21 09:08:12.233038	2022-05-26 09:46:00	1449	Sem afastamento 
198	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Saida	2022-05-21 10:28:02.837496	2025-10-01 09:32:00	1196	Sem afastamento 
199	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Entrada	2022-06-11 20:01:27.237873	2024-03-02 09:50:00	1952	Sem afastamento 
200	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Saida	2022-06-11 20:01:30.966611	2024-03-02 09:50:00	1951	Sem afastamento 
201	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Saida	2022-06-11 20:01:45.222847	2025-10-01 09:32:00	1195	Sem afastamento 
202	ACESSO LIBERADO	Ricardo	Coração de Leão			RICARDO	ATIVO	Entrada	2022-06-11 20:01:48.28713	2025-10-01 09:32:00	1194	Sem afastamento 
203	ACESSO LIBERADO	Pedro	Álvares Cabral			PEDRO	ATIVO	Entrada	2022-06-11 20:01:55.16388	2026-11-18 09:41:00	1519	Sem afastamento 
204	ACESSO LIBERADO	Frida	Kahlo			FRIDA	ATIVO	Saida	2022-06-11 20:02:04.05585	2024-03-02 09:50:00	1950	Sem afastamento 
\.


--
-- TOC entry 2978 (class 0 OID 16653)
-- Dependencies: 206
-- Data for Name: tb_tipo_afastamento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_tipo_afastamento (id_afastamento, nome_afastamento, fg_tempo_afastamento) FROM stdin;
2clfuscy	Sem afastamento 	00:00:00
96elqd8z	Viagem de Negocios	91 days
360fti1g	Ferias	30 days
\.


--
-- TOC entry 2969 (class 0 OID 16572)
-- Dependencies: 196
-- Data for Name: tb_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_usuarios (id_usuario, foto_usuario, nome_usuario, sobrenome_usuario, tipo_documento_usuario, numero_documento_usuario, telefone_usuario, email_usuario, empresa_usuario, tipo_usuario, setor_usuario, pais_usuario, estado_usuario, cidade_usuario, rua_usuario, numero_usuario, crendencial_usuario) FROM stdin;
8jof3kmn		Tito	De Souza	CPF	56223441122	31 99999-99999		AGU	Comum	Fiscalização						1524
9157hr7n		Caio	Júlio Cesar	RG	43324423	31 99999-0999	julio@joaoacesso.com	Governo Romano	Comum	Governo	Itália	Roma		Dos Romanos		1606BD1Q8
9aha12ti		Cleópatra	VII Filopátor	RG	55555555222	31 99999-99999	cleo@joaoacesso.com	Novo Egito Ptolemaico	Comum	Governo	Egito	Desconhecido	Desconhecida	Ruas da Areias	30	CLEO
2h8wjaat		Carlos	Magno	CPF	555555533	31 99999-9999	carlos@joaoacesso.com	Magno	Comum		Frância			28 de janeiro	768	CARLOS
5ubomf2t		Ricardo	Coração de Leão	CPF	5555566	31 99999-99999	ricardo@joaoacesso.com		Comum		Inglaterra			6 de abril		RICARDO
5n6vx2y		Pedro	Álvares Cabral	CPF	555555533	31 9999-9999	pedro@joaoacesso.com	Escola de Sagres	Comum	Martimos	Portugal	Belmonte			53	PEDRO
2d1po2ax		Cristóvão	Colombo	CNPJ	15555555	31 9999-5555	colombo@email.com	colombo	Comum		Itália	Génova		20 de maio	1451	COLOMBO
h8bzwvyg		Frida	Kahlo	CPF	55555666	31 9999-555	kahlo@email.com	Museu Frida Kahlo	Comum		México	Coyoacán			1954	FRIDA
hkrxkrn1		Leonardo	da Vinci	CPF	552222	31 9999-9999	leonardo@email.com		Comum	Diversas Coisa	Reino da França	Amboise		15 de abril 	1519	MONALISA
ip9uausi		Mariana	Santos	CPF	3344434	(31)4343-3217	email@email.com	Salto Burgo	Comum	Comoera	Cuba	La paz	Sertao	Rua das Compodia 	n23	AAA
gtp6q8dk		Michelangelo	di Lodovico	CPF	555556666	31 0000-0000	michelangelo	Alta Renascença LTDA	Comum		Itália	Roma	Caprese Michelangelo 	18 de fevereiro	1564	MICHELANGELO
fk4oco1s		Tutankhamon	Décimo Oitavo	CPF	5522222	31 99999-99999	tutankhamon@email.com	Reino do Egito	Comum		Egito		Vale dos Reis		1 323	TUTAN
3djutwcp		Desenvolvedor	De Teste	CPF	432432	432432432			Comum							TESTE
kr5ibetu		Joao Guilherme	Tito de Jesus	CPF	44444444	(31)3456-3217	email@email.com		Comum	Desevolvimento de Software	Brasil	MG	Belo Horizonte			93S97NQR2
\.


--
-- TOC entry 2970 (class 0 OID 16589)
-- Dependencies: 197
-- Data for Name: tbcredencial_cadastradas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbcredencial_cadastradas (id_credencial, situacao_credencial, data_inicial_credencial, data_final_credencial, direcao, credencial, credito_credencial, tempo_afastamento) FROM stdin;
9157hr7n	ATIVO	2022-05-17 20:45:22.461944	2026-05-27 20:43:00	Entrada	1606BD1Q8	899998	00:00:00
8jof3kmn	ATIVO	2022-05-14 18:15:32.903187	2025-06-14 18:16:00	Entrada	1524	799994	00:00:00
ip9uausi	ATIVA	2022-03-23 21:36:48.853064	2025-08-20 00:00:00	Entrada	AAA	7	00:00:00
2h8wjaat	ATIVO	2022-05-18 09:30:03.527912	2022-06-30 09:26:00	Entrada	CARLOS	100000	00:00:00
3djutwcp	ATIVO	2022-05-19 19:38:38.252207	2026-06-03 19:37:00	Entrada	TESTE	1000	00:00:00
2d1po2ax	ATIVO	2022-05-18 09:47:31.451109	2022-05-26 09:46:00	Entrada	COLOMBO	1448	00:00:00
5ubomf2t	ATIVO	2022-05-18 09:33:16.391643	2025-10-01 09:32:00	Entrada	RICARDO	1193	00:00:00
5n6vx2y	ATIVO	2022-05-18 09:44:13.385559	2026-11-18 09:41:00	Entrada	PEDRO	1518	00:00:00
gtp6q8dk	ATIVO	2022-05-18 10:49:18.937981	2023-11-18 10:34:00	Entrada	MICHELANGELO	1563	00:00:00
h8bzwvyg	ATIVO	2022-05-18 09:54:43.795789	2024-03-02 09:50:00	Entrada	FRIDA	1949	00:00:00
kr5ibetu	ATIVA	2022-05-08 17:43:23.065762	2027-08-20 00:00:00	Entrada	93S97NQR2	45449	00:00:00
9aha12ti	ATIVO	2022-05-18 09:20:02.843994	2031-06-10 09:17:00	Entrada	CLEO	99995	00:00:00
fk4oco1s	ATIVO	2022-06-17 16:57:53.831237	2024-06-24 16:52:00	Entrada	TUTAN	997	30 days
hkrxkrn1	ATIVO	2022-05-18 09:59:36.549526	2024-07-10 09:58:00	Entrada	MONALISA	1516	00:00:00
\.


--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 211
-- Name: tb_email_config_id_email_config_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_email_config_id_email_config_seq', 2, true);


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 200
-- Name: tb_registrar_gestor_id_gestor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_registrar_gestor_id_gestor_seq', 81, true);


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 202
-- Name: tb_registro_acessos_id_acesso_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_registro_acessos_id_acesso_seq', 51, true);


--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 203
-- Name: tb_registro_acessos_id_acesso_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_registro_acessos_id_acesso_seq1', 238, true);


--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 205
-- Name: tb_relatorios_acessos_id_relatorio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_relatorios_acessos_id_relatorio_seq', 204, true);


--
-- TOC entry 2999 (class 0 OID 0)
-- Dependencies: 207
-- Name: tb_usuarios_id_usuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_usuarios_id_usuario_seq', 1, false);


--
-- TOC entry 3000 (class 0 OID 0)
-- Dependencies: 208
-- Name: tbcredencial_cadastradas_id_credencial_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbcredencial_cadastradas_id_credencial_seq', 1, false);


--
-- TOC entry 2828 (class 2606 OID 16675)
-- Name: tb_registrar_gestor tb_registrar_gestor_email_gestor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_registrar_gestor
    ADD CONSTRAINT tb_registrar_gestor_email_gestor_key UNIQUE (email_gestor);


--
-- TOC entry 2830 (class 2606 OID 16677)
-- Name: tb_registrar_gestor tb_registrar_gestor_login_gestor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_registrar_gestor
    ADD CONSTRAINT tb_registrar_gestor_login_gestor_key UNIQUE (login_gestor);


--
-- TOC entry 2832 (class 2606 OID 16679)
-- Name: tb_registrar_gestor tb_registrar_gestor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_registrar_gestor
    ADD CONSTRAINT tb_registrar_gestor_pkey PRIMARY KEY (id_gestor);


--
-- TOC entry 2834 (class 2606 OID 16681)
-- Name: tb_registrar_gestor tb_registrar_gestor_senha_gestor_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_registrar_gestor
    ADD CONSTRAINT tb_registrar_gestor_senha_gestor_key UNIQUE (senha_gestor);


--
-- TOC entry 2836 (class 2606 OID 16683)
-- Name: tb_registro_acessos tb_registro_acessos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_registro_acessos
    ADD CONSTRAINT tb_registro_acessos_pkey PRIMARY KEY (id_acesso);


--
-- TOC entry 2838 (class 2606 OID 16685)
-- Name: tb_relatorios_acessos tb_relatorios_acessos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_relatorios_acessos
    ADD CONSTRAINT tb_relatorios_acessos_pkey PRIMARY KEY (id_relatorio);


--
-- TOC entry 2840 (class 2606 OID 16687)
-- Name: tb_tipo_afastamento tb_tipo_afastamento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_tipo_afastamento
    ADD CONSTRAINT tb_tipo_afastamento_pkey PRIMARY KEY (fg_tempo_afastamento);


--
-- TOC entry 2820 (class 2606 OID 16689)
-- Name: tb_usuarios tb_usuarios_crendencial_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_usuarios
    ADD CONSTRAINT tb_usuarios_crendencial_usuario_key UNIQUE (crendencial_usuario);


--
-- TOC entry 2822 (class 2606 OID 16691)
-- Name: tb_usuarios tb_usuarios_id_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_usuarios
    ADD CONSTRAINT tb_usuarios_id_usuario_key UNIQUE (id_usuario);


--
-- TOC entry 2824 (class 2606 OID 16693)
-- Name: tbcredencial_cadastradas tbcredencial_cadastradas_credencial_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbcredencial_cadastradas
    ADD CONSTRAINT tbcredencial_cadastradas_credencial_key UNIQUE (credencial);


--
-- TOC entry 2826 (class 2606 OID 16695)
-- Name: tbcredencial_cadastradas tbcredencial_cadastradas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbcredencial_cadastradas
    ADD CONSTRAINT tbcredencial_cadastradas_pkey PRIMARY KEY (id_credencial);


--
-- TOC entry 2843 (class 2620 OID 16696)
-- Name: tbcredencial_cadastradas tr_adicionar_afastamento; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_adicionar_afastamento AFTER INSERT ON public.tbcredencial_cadastradas FOR EACH ROW EXECUTE PROCEDURE public.pr_update_datainicial();


--
-- TOC entry 2844 (class 2620 OID 16697)
-- Name: tb_registro_acessos tr_baixa_acessos; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_baixa_acessos AFTER INSERT ON public.tb_registro_acessos FOR EACH ROW EXECUTE PROCEDURE public.pr_baixa_acessos();


--
-- TOC entry 2842 (class 2620 OID 16698)
-- Name: tb_usuarios tr_delete_credencial; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tr_delete_credencial AFTER DELETE ON public.tb_usuarios FOR EACH ROW EXECUTE PROCEDURE public.pr_trig_delete_credencial();


--
-- TOC entry 2841 (class 2606 OID 16699)
-- Name: tbcredencial_cadastradas tbcredencial_cadastradas_tempo_afastamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbcredencial_cadastradas
    ADD CONSTRAINT tbcredencial_cadastradas_tempo_afastamento_fkey FOREIGN KEY (tempo_afastamento) REFERENCES public.tb_tipo_afastamento(fg_tempo_afastamento);


-- Completed on 2023-03-20 19:37:29

--
-- PostgreSQL database dump complete
--

