create or replace FUNCTION FN_GUION 
(
  IN_VALOR IN VARCHAR2 
) RETURN VARCHAR2 AS
l_retorno VARCHAR2(1);
BEGIN
  IF IN_VALOR IS NOT NULL THEN
    l_retorno := '-';
    ELSE
    l_retorno := null;
  END IF;
  RETURN l_retorno;
END FN_GUION;