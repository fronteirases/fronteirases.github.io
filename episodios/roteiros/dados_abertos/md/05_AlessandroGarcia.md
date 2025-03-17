**Audios**

**Conversa**

-   

**Encerramento:**

-   

**Youtube:
[[http://www.youtube.com/watch?v=CMkBQblzeCo]{.underline}](http://www.youtube.com/watch?v=CMkBQblzeCo)**

**Fronteiras da Engenharia de Software - Podcast**

Host: Adolfo Neto (UTFPR)

[Co-host: Gustavo Pinto (UFPA)]{.mark}

Equipe: Marco Tulio Valente (UFMG), Danilo Ribeiro (Zup), Leonardo
Fernandes (IFAL), Fabio Petrillo (Univ. Quebec), Marcela dos Santos
(Univ. Quebec)

**Introdução ao Episódio**

\[ADOLFO\] Olá ouvintes, eu sou Adolfo Neto, professor da Universidade
Tecnológica Federal do Paraná.

[\[GUSTAVO\] E eu sou Gustavo Pinto, professor da UFPA, e este é o
Fronteiras da Engenharia de Software, um podcast feito para refletir
sobre o presente e futuro da engenharia de software]{.mark}

\[ADOLFO\] Fronteiras da Engenharia de Software é um podcast de
divulgação científica que discute mensalmente diversificados temas da
Engenharia de Software. Os episódios abordam desde questões fundamentais
da engenharia de software até os mais recentes avanços na área.

[\[GUSTAVO\] Para o nosso quinto episódio, entrevistamos Alessandro
Garcia que é um professor que tem umas duas décadas de experiência em
trabalhos de pesquisa, inovação e desenvolvimento em engenharia de
software. Hoje alessandro é professor na PUC-RJ, onde lidera o Opus
Research Group.]{.mark}

\[ADOLFO\] Nos últimos anos, Alessandro tem trabalhado bastante com
degradação de design e refatoração. Então, se você escutou e gostou o
último episódio do Marcelo maia Sobre code smells, deve também gostar
desse sobre refatoração (e como evitar code smells). Vem com a gente!

**Episódio 05: Refactoring, com Alessandro Garcia (PUC-Rio)**

**Parte 1: Apresentação \[5 min, estimativa\]**

\[ADOLFO\] Olá ouvintes, para este quarto episódio, contamos com a
presença de Alessandro Garcia, que é professor na PUC-Rio.

Tudo bem, Alessandro? Você pode se apresentar para as pessoas que nos
escutam?

[\[GUSTAVO\] Você atua em engenharia de software há alguma longa data.
Olhando seus trabalhos recentes, você parece ter um interesse]{.mark}
[bem diversificado. Em que parte da engenharia de software você mais
concentra seus esforços hoje?]{.mark}

**Parte 2 - Refactoring \[20 min, estimativa\]**

[\[GUSTAVO\] Alessandro, você é um dos pesquisadores brasileiros mais
ativos na área de refatoração. Conta pra gente, o que é refatorar um
código? \<AGUARDAR RESPONDER\> O termo refactoring vem de uma tese de
doutorado lá da década de 80, do William Opdyke e o Ralph Johnson. Mas
hoje em dia podemos dizer que refactoring é onipresente no dia a dia do
desenvolvedor. Como você enxerga todo esse sucesso de refactoring? O que
propiciou todo esse avanço?]{.mark}

\[ADOLFO\] Por que refatoração é importante? Quando eu sei que é o
momento de refatorar meu código? Devo refatorar sempre?

\[ADOLFO\] Há várias refatorações conhecidas, como mover método entre
classes ou extrair um método de uma classe. Existe alguma refatoração
mais importante? Ou existe uma refatoração que acontece com mais
frequência?

[\[GUSTAVO\] Refatorações são mudanças pontuais no código, como no caso
de um move method? Refactoring são atômicos? Ou existem refatorações
mais "grandiosas", como por exemplo quando eu quero mudar um framework
no meu projeto? Poderia dizer que isso é uma refatoração? Ou quando eu
quero extrair um módulo do meu código? Isso também é refatorar?]{.mark}

\[ADOLFO\] Refatorar está na agenda do desenvolvedor? É comum os
desenvolvedores refatorarem código? Ou se fala muito e se faz pouco?
\<AGUARDAR\> Pra refatorar, eu preciso primeiro ter um code smell? Ou
faz sentido refatorar código limpo?

[\[GUSTAVO\] Conversando com Marcelo Maia no último episódio, nós
discutimos que se o desenvolvedor não tiver testes automatizados, a
refatoração pode acabar com um tiro no pé, inserindo um bug.... Pq isso
acontece? É difícil refatorar? Falta apoio de ferramentas pra refatorar?
\<AGUARDAR\> Quais práticas de desenvolvimento de software podem apoiar
desenvolvedores que gostam de refatorar código?]{.mark}

\[ADOLFO\] Qual é o status atual das ferramentas de refatoração? Dá pra
confiar nelas? Elas dão mais trabalho do que ajudam?

**Parte 3 - Pesquisa em Refactoring \[20 min, estimativa\]**

[\[GUSTAVO\] Alessandro, você tem vários trabalhos sobre batch
refactoring. Explica pra gente, o que seria refatorar em batches? Em que
contexto isso faz sentido? Quais são as classes de problemas que eu
consigo resolver com batch refactoring?]{.mark}

\[ADOLFO\] E como eu faço batch refactoring? Manualmente? Ou existe
alguma ferramenta que pode ajudar? Que cuidados eu, como desenvolvedor,
devo ter?

[\[GUSTAVO\] E como funciona pra organizar esses refactorings em
batches? Como eu sei qual deve vir primeiro, segundo, terceiro?]{.mark}

[Batch refactoring pode trazer problemas? E como eu conseguiria
minimizar eventuais problemas causados por um batch refactoring mal
feito?]{.mark}

~~\[ADOLFO\] Há um outro trabalho em que você investiga se refactoring
está de fato removendo os problemas de design. O que isso quer dizer? É
possível refatorar um código e não remover um problema de design?~~

[~~\[GUSTAVO\] Esses trabalhos são feitos sempre usando linguagens de
tipagem forte, como Java, C, C#, etc. No entanto, linguagens de tipagem
fraca, como Python, Ruby, JavaScript, etc, estão em plena adoção. O
próprio livro do Martin Fowler, segunda edição, é usando JavaScript.
Qual é o estado da arte em refatoração de programas com tipagem
fraca?~~]{.mark}

**Parte 5 - Indicações**

[\[GUSTAVO\] ~~Alguma mensagem para nossos ouvintes?~~ Quem estiver
interessado em começar a estudar/pesquisar refactoring, por onde deve
começar? Recomendação de livro ou algum outro material?]{.mark}

**Parte 6: Conclusão \[3 min, estimativa\]**

\[ADOLFO\] Para você, qual é a próxima fronteira da engenharia de
software?

**Texto para divulgação**

> Na entrevista de hoje conversamos com Alessandro Garcia, professor da
> PUC-Rio, sobre degradação de design e refatoração. Ele é Professor
> Associado do Departamento de Informática, onde atua na área de
> Engenharia de Software. Lá ele investiga técnicas para construção ágil
> de programas com qualidade.

Sites do Alessandro

-   [[[http://www.inf.puc-rio.br/blog/professor/@alessandro-garcia]{.underline}]{.mark}](http://www.inf.puc-rio.br/blog/professor/@alessandro-garcia)

-   [[[https://dblp.org/pid/g/AlessandroFGarcia.html]{.underline}]{.mark}](https://dblp.org/pid/g/AlessandroFGarcia.html)

-   [[[https://scholar.google.com/citations?user=rP1LYboAAAAJ&hl=en]{.underline}]{.mark}](https://scholar.google.com/citations?user=rP1LYboAAAAJ&hl=en)

-   [[[https://twitter.com/alessfgarcia]{.underline}]{.mark}](https://twitter.com/alessfgarcia)

[**Extra (opcional)**:]{.mark}

-   [Alguma parceria com a indústria ou alguma pesquisa que tenha sido
    > feita e depois foi adotada por alguma ferramenta amplamente
    > usada?]{.mark}
