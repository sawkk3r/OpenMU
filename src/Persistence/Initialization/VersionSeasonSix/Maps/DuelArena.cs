// <copyright file="DuelArena.cs" company="MUnique">
// Licensed under the MIT License. See LICENSE file in the project root for full license information.
// </copyright>

namespace MUnique.OpenMU.Persistence.Initialization.VersionSeasonSix.Maps;

using MUnique.OpenMU.DataModel.Configuration;
using MUnique.OpenMU.DataModel.Configuration.Items;

/// <summary>
/// Map initialization for the duel arena map.
/// </summary>
internal class DuelArena : BaseMapInitializer
{
    /// <summary>
    /// The Number of the Map.
    /// </summary>
    internal const byte Number = 64;

    /// <summary>
    /// The Name of the Map.
    /// </summary>
    internal const string Name = "Duel Arena";

    /// <summary>
    /// Initializes a new instance of the <see cref="DuelArena"/> class.
    /// </summary>
    /// <param name="context">The context.</param>
    /// <param name="gameConfiguration">The game configuration.</param>
    public DuelArena(IContext context, GameConfiguration gameConfiguration)
        : base(context, gameConfiguration)
    {
    }

    /// <inheritdoc/>
    protected override byte MapNumber => Number;

    /// <inheritdoc/>
    protected override string MapName => Name;

    /// <inheritdoc/>
    protected override byte SafezoneMapNumber => Lorencia.Number;

    /// <inheritdoc/>
    /// <remarks>
    /// Os spots aqui foram pensados para ficarem distribuídos pelas "gaiolas" e áreas centrais da Arena.
    /// Depois de inicializar a base de dados, você ainda pode ajustar as posições finas pelo Map Editor no painel web.
    /// </remarks>
    protected override IEnumerable<MonsterSpawnArea> CreateMonsterSpawns()
    {
        // Números dos monstros já existentes na configuração (veja inicializadores de mapas/skills):
        //  40  - Death Knight          (LostTower)
        //  16  - Elite Skeleton        (Dungeon)
        //  63  - Death Beam Knight     (Tarkan)
        // 150  - Bali                   (Special Summon)
        // 309  - Hell Maine            (Aida)
        // 445  - Shadow Knight         (Swamp Of Calmness)
        // 549  - Bloody Orc            (Aida)
        //  79  - Golden Dragon         (Invasion)

        // Garante que todos os monstros existem na configuração atual.
        var deathKnight     = this.NpcDictionary[40];
        var eliteSkeleton   = this.NpcDictionary[16];
        var deathBeamKnight = this.NpcDictionary[63];
        var bali            = this.NpcDictionary[150];
        var hellMaine       = this.NpcDictionary[309];
        var shadowKnight    = this.NpcDictionary[445];
        var bloodyOrc       = this.NpcDictionary[549];
        var goldenDragon    = this.NpcDictionary[79];

        short id = 1;

        // As coordenadas X/Y foram estimadas para ficarem dentro das "gaiolas" e áreas acessíveis
        // que aparecem no minimapa da Duel Arena. Caso algum spot fique em parede, ajuste no Map Editor.

        // Gaiola 1 - Death Knight, melee contínuo.
        yield return this.CreateMonsterSpawn(
            id++,
            deathKnight,
            x1: 30, x2: 36,
            y1: 32, y2: 38,
            quantity: 15,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Gaiola 2 - Elite Skeleton, respawn rápido.
        yield return this.CreateMonsterSpawn(
            id++,
            eliteSkeleton,
            x1: 48, x2: 54,
            y1: 32, y2: 38,
            quantity: 18,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Gaiola 3 - Bali, rápido e agressivo.
        yield return this.CreateMonsterSpawn(
            id++,
            bali,
            x1: 66, x2: 72,
            y1: 32, y2: 38,
            quantity: 15,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Gaiola 4 - Bloody Orc, mid/late Arena.
        yield return this.CreateMonsterSpawn(
            id++,
            bloodyOrc,
            x1: 84, x2: 90,
            y1: 32, y2: 38,
            quantity: 10,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Gaiola 5 - Death Beam Knight, spot premium de dano alto.
        yield return this.CreateMonsterSpawn(
            id++,
            deathBeamKnight,
            x1: 30, x2: 36,
            y1: 52, y2: 58,
            quantity: 10,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Gaiola 6 - Shadow Knight, equilíbrio entre dano e resistência.
        yield return this.CreateMonsterSpawn(
            id++,
            shadowKnight,
            x1: 48, x2: 54,
            y1: 52, y2: 58,
            quantity: 12,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Gaiola 7 - Hell Maine, hard mode (quantidade menor, dano alto).
        yield return this.CreateMonsterSpawn(
            id++,
            hellMaine,
            x1: 66, x2: 72,
            y1: 52, y2: 58,
            quantity: 5,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Gaiola 8 - Mix de pressão e XP com Bloody Orc.
        yield return this.CreateMonsterSpawn(
            id++,
            bloodyOrc,
            x1: 84, x2: 90,
            y1: 52, y2: 58,
            quantity: 12,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Área central da Arena - Golden Dragon, spawn psicológico / PvP.
        yield return this.CreateMonsterSpawn(
            id++,
            goldenDragon,
            x1: 72, x2: 78,
            y1: 76, y2: 82,
            quantity: 2,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);

        // Plataforma externa - Death Knight + elites para treino pesado.
        yield return this.CreateMonsterSpawn(
            id++,
            deathKnight,
            x1: 110, x2: 116,
            y1: 80, y2: 86,
            quantity: 20,
            direction: Direction.South,
            spawnTrigger: SpawnTrigger.Automatic);
    }
}