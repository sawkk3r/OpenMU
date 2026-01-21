// <copyright file="DevilSquareStartConfiguration.cs" company="MUnique">
// Licensed under the MIT License. See LICENSE file in the project root for full license information.
// </copyright>

namespace MUnique.OpenMU.GameLogic.PlugIns.PeriodicTasks;

/// <summary>
/// The devil square start configuration.
/// </summary>
public class DevilSquareStartConfiguration : MiniGameStartConfiguration
{
    /// <summary>
    /// Gets the default configuration for devil square.
    /// </summary>
    public static DevilSquareStartConfiguration Default =>
        new()
        {
            // Envia aviso 1 minuto antes de abrir a entrada.
            PreStartMessageDelay = TimeSpan.FromMinutes(1),
            // Mensagem global exibida quando faltar 1 minuto para abrir.
            Message = "Falta 1 minuto para abrir o DEVIL SQUARE.",
            EntranceOpenedMessage = "Devil Square entrance is open and closes in {0} minute(s).",
            EntranceClosedMessage = "Devil Square entrance closed.",
            TaskDuration = TimeSpan.FromMinutes(25),
            // Intervalo padrão alterado de 240 minutos para 5 minutos,
            // permitindo que o evento seja iniciado com muito mais frequência.
            Timetable = PeriodicTaskConfiguration.GenerateTimeSequence(TimeSpan.FromMinutes(5)).ToList(),
        };
}