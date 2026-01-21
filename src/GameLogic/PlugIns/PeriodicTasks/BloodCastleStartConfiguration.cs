// <copyright file="BloodCastleStartConfiguration.cs" company="MUnique">
// Licensed under the MIT License. See LICENSE file in the project root for full license information.
// </copyright>

namespace MUnique.OpenMU.GameLogic.PlugIns.PeriodicTasks;

/// <summary>
/// The blood castle start configuration.
/// </summary>
public class BloodCastleStartConfiguration : MiniGameStartConfiguration
{
    /// <summary>
    /// Gets the default configuration for blood castle.
    /// </summary>
    public static BloodCastleStartConfiguration Default =>
        new()
        {
            // Envia aviso 1 minuto antes de abrir a entrada.
            PreStartMessageDelay = TimeSpan.FromMinutes(1),
            // Mensagem global exibida quando faltar 1 minuto para abrir.
            Message = "Falta 1 minuto para abrir o BLOOD CASTLE.",
            EntranceOpenedMessage = "Blood Castle entrance is open and closes in {0} minute(s).",
            EntranceClosedMessage = "Blood Castle entrance closed.",
            TaskDuration = TimeSpan.FromMinutes(20),
            // Intervalo padrão alterado de 120 minutos para 5 minutos,
            // permitindo que o evento seja iniciado com muito mais frequência.
            Timetable = GenerateTimeSequence(TimeSpan.FromMinutes(5)).ToList(),
        };
}